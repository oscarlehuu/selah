import Foundation
import RevenueCat
import Observation

enum SubscriptionTier: String, CaseIterable {
    case weekly, monthly, yearly

    var productId: String {
        switch self {
        case .weekly: "com.lilgroup.selah.weekly"
        case .monthly: "com.lilgroup.selah.monthly"
        case .yearly: "com.lilgroup.selah.yearly"
        }
    }

    var title: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }

    var priceLabel: String {
        switch self {
        case .weekly: "$7.99 / week"
        case .monthly: "$14.99 / month"
        case .yearly: "$49.99 / year"
        }
    }

    var shortPrice: String {
        switch self {
        case .weekly: "$7.99"
        case .monthly: "$14.99"
        case .yearly: "$49.99"
        }
    }

    var ctaPrice: String {
        switch self {
        case .weekly: "$7.99/wk"
        case .monthly: "$14.99/mo"
        case .yearly: "$49.99/yr"
        }
    }

    var detailLabel: String {
        switch self {
        case .weekly: "Billed every week"
        case .monthly: "Billed every month"
        case .yearly: "$4.16 / month · save 72%"
        }
    }
}

@MainActor
@Observable
final class SubscriptionService {
    var isSubscribed = false
    var packages: [Package] = []
    var isLoading = false
    var lastError: String?
    var paywallPresentationCount = 0

    private var configured = false

    func configure(demoMode: Bool) {
        if demoMode {
            isSubscribed = true
            return
        }
        guard !configured else { return }
        configured = true
        Purchases.logLevel = .warn
        Purchases.configure(withAPIKey: AppConfiguration.revenueCatPublicAPIKey)
        Task { await refreshCustomerInfo() }
        Task { await loadOfferings() }
    }

    func incrementPaywallPresentation() {
        paywallPresentationCount += 1
    }

    func refreshCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isSubscribed = info.entitlements["premium"]?.isActive == true
        } catch {
            lastError = error.localizedDescription
        }
    }

    func loadOfferings() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let offerings = try await Purchases.shared.offerings()
            packages = offerings.current?.availablePackages ?? []
        } catch {
            lastError = error.localizedDescription
        }
    }

    func package(for tier: SubscriptionTier) -> Package? {
        packages.first { $0.storeProduct.productIdentifier == tier.productId }
    }

    func purchase(_ tier: SubscriptionTier, surface: String) async -> Bool {
        guard let package = package(for: tier) else {
            lastError = "This plan isn’t available yet. Try Restore, or open Selah on a device signed into the App Store."
            return false
        }
        return await purchase(package, surface: surface)
    }

    func purchase(_ package: Package, surface: String) async -> Bool {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            isSubscribed = result.customerInfo.entitlements["premium"]?.isActive == true
            if isSubscribed {
                AnalyticsService.track("subscribe", properties: [
                    "tier": package.storeProduct.productIdentifier,
                    "surface": surface
                ])
            }
            return isSubscribed
        } catch {
            if (error as NSError).code == ErrorCode.purchaseCancelledError.rawValue {
                AnalyticsService.track("paywall_payment_sheet_cancelled")
            }
            lastError = error.localizedDescription
            return false
        }
    }

    func restore() async -> Bool {
        do {
            let info = try await Purchases.shared.restorePurchases()
            isSubscribed = info.entitlements["premium"]?.isActive == true
            AnalyticsService.track("restore_tap")
            return isSubscribed
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }
}
