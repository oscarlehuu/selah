import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var restoreMessage: String?
    @State private var showCrisis = false
    @State private var showPrivacy = false
    @State private var showDisclaimer = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    subscriptionCard
                    settingsGroup("Privacy") {
                        SettingsRow(icon: "icloud.slash", label: "On-device AI") {
                            Text("Always on")
                                .font(SelahFont.ui(.footnote))
                                .foregroundStyle(SelahColors.textMuted)
                        }
                        rowDivider
                        SettingsRow(icon: "trash", label: "Auto-delete sessions") {
                            Toggle("", isOn: autoDeleteBinding)
                                .labelsHidden()
                                .tint(Color(hex: 0x34C759))
                        }
                        rowDivider
                        SettingsRow(icon: "shield", label: "How privacy works", chevron: true) {
                            showPrivacy = true
                        }
                    }
                    settingsGroup("Daily rhythm") {
                        SettingsRow(icon: "bell", label: "Morning verse") {
                            DatePicker("", selection: reminderTimeBinding, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        rowDivider
                        SettingsRow(icon: "book", label: "Translation") {
                            Text("KJV")
                                .font(SelahFont.ui(.footnote))
                                .foregroundStyle(SelahColors.textMuted)
                        }
                        rowDivider
                        SettingsRow(icon: "square.grid.2x2", label: "Lock Screen widget") {
                            Text("Soon")
                                .font(SelahFont.ui(.footnote))
                                .foregroundStyle(SelahColors.textMuted)
                        }
                    }
                    settingsGroup("Care") {
                        SettingsRow(icon: "phone", label: "Urgent help & hotlines", style: .gold, chevron: true) {
                            showCrisis = true
                        }
                        rowDivider
                        SettingsRow(icon: "exclamationmark.triangle", label: "What Selah is not", chevron: true) {
                            showDisclaimer = true
                        }
                    }
                    settingsGroup("Legal & support") {
                        if let url = URL(string: AppConfiguration.privacyPolicyURL) {
                            SettingsLinkRow(icon: "doc.text", label: "Privacy Policy", url: url)
                            rowDivider
                        }
                        if let url = URL(string: AppConfiguration.termsURL) {
                            SettingsLinkRow(icon: "doc.text", label: "Terms of Use", url: url)
                            rowDivider
                        }
                        if let url = URL(string: "mailto:\(AppConfiguration.supportEmail)") {
                            SettingsLinkRow(icon: "envelope", label: "Contact support", url: url)
                        }
                    }
                    Text("Selah v1.0 · Made for quiet mornings.")
                        .font(SelahFont.ui(.caption))
                        .foregroundStyle(SelahColors.textSoft)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 26)
            }
        }
        .background(SelahColors.background.ignoresSafeArea())
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(22)
        .alert("What Selah is not", isPresented: $showDisclaimer) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(OnboardingCopy.companionDisclaimer)
        }
        .sheet(isPresented: $showCrisis) { CrisisResourcesView() }
        .sheet(isPresented: $showPrivacy) { PrivacyInfoView() }
        .onAppear { AnalyticsService.track("settings_open") }
    }

    // MARK: - Header (simple title row, no NavigationStack chrome)

    private var header: some View {
        HStack {
            Text("Settings")
                .font(SelahFont.display(.title3))
                .fontWeight(.semibold)
                .foregroundStyle(SelahColors.text)
            Spacer()
            Button("Done") { dismiss() }
                .font(SelahFont.ui(.body, weight: .semibold))
                .foregroundStyle(SelahColors.primaryDeep)
        }
        .padding(.horizontal, 22)
        .padding(.top, 22)
        .padding(.bottom, 14)
    }

    // MARK: - Subscription sub-card (mock `.sub-card`)

    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(env.isSubscribed ? "Selah · Yearly" : "Not subscribed")
                .font(SelahFont.display(.headline))
                .foregroundStyle(SelahColors.text)
            Text(env.isSubscribed ? "$49.99/year" : "Subscribe to unlock everything.")
                .font(SelahFont.ui(.footnote))
                .foregroundStyle(SelahColors.textMuted)
            HStack(spacing: 8) {
                quietButton("Manage") {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                quietButton("Restore", identifier: "settings.restore", action: restore)
            }
            .padding(.top, 8)
            if let restoreMessage {
                Text(restoreMessage)
                    .font(SelahFont.ui(.caption))
                    .foregroundStyle(SelahColors.textMuted)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [SelahColors.primarySoft, Color(hex: 0xFDFAF3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SelahColors.primary.opacity(0.18), lineWidth: 1)
        )
    }

    private func quietButton(_ title: String, identifier: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(SelahFont.ui(.footnote, weight: .semibold))
                .foregroundStyle(SelahColors.text)
                .padding(.horizontal, 14)
                .frame(minHeight: 34)
                .background(SelahColors.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(SelahColors.borderStrong, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier ?? "")
    }

    // MARK: - Group scaffolding (mock `.set-group` / `.set-list`)

    private func settingsGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(SelahFont.ui(.caption, weight: .bold))
                .textCase(.uppercase)
                .kerning(0.8)
                .foregroundStyle(SelahColors.textSoft)
            VStack(spacing: 0) { content() }
                .background(SelahColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(SelahColors.border, lineWidth: 1)
                )
                .shadow(color: Color(hex: 0x2C2825).opacity(0.06), radius: 4, y: 2)
        }
    }

    private var rowDivider: some View {
        Divider().overlay(SelahColors.border).padding(.leading, 56)
    }

    // MARK: - Bindings / actions (unchanged logic)

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = env.settings?.notificationHour ?? 6
                components.minute = env.settings?.notificationMinute ?? 30
                return Calendar.current.date(from: components) ?? .now
            },
            set: { date in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                let hour = comps.hour ?? 6
                let minute = comps.minute ?? 30
                env.settings?.notificationHour = hour
                env.settings?.notificationMinute = minute
                env.persist()
                NotificationScheduler.scheduleDaily(hour: hour, minute: minute)
            }
        )
    }

    private var autoDeleteBinding: Binding<Bool> {
        Binding(
            get: { env.settings?.autoDeleteTalkSessions ?? false },
            set: { value in
                env.settings?.autoDeleteTalkSessions = value
                env.persist()
            }
        )
    }

    private func restore() {
        Task {
            let ok = await env.subscription.restore()
            restoreMessage = ok ? "Subscription active." : "No subscription found."
        }
    }
}

// MARK: - Row components (mock `.set-row` with 30pt icon tile)

private struct SettingsRow<Trailing: View>: View {
    let icon: String
    let label: String
    var style: SelahChip.Style = .blue
    @ViewBuilder var trailing: Trailing

    init(icon: String, label: String, style: SelahChip.Style = .blue, @ViewBuilder trailing: () -> Trailing) {
        self.icon = icon
        self.label = label
        self.style = style
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 12) {
            SelahIconTile(systemImage: icon, size: 30, radius: 9, style: style)
            Text(label)
                .font(SelahFont.ui(.subheadline, weight: .semibold))
                .foregroundStyle(SelahColors.text)
            Spacer()
            trailing
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 50)
    }
}

extension SettingsRow where Trailing == AnyView {
    /// Tappable chevron row.
    init(icon: String, label: String, style: SelahChip.Style = .blue, chevron: Bool, action: @escaping () -> Void) {
        self.init(icon: icon, label: label, style: style) {
            AnyView(
                Button(action: action) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(SelahColors.textSoft)
                }
                .buttonStyle(.plain)
            )
        }
    }
}

private struct SettingsLinkRow: View {
    let icon: String
    let label: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                SelahIconTile(systemImage: icon, size: 30, radius: 9, style: .blue)
                Text(label)
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(SelahColors.textSoft)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 50)
        }
    }
}
