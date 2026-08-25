import SwiftUI

struct SelahCompactHeader<Left: View, Right: View>: View {
    let title: String
    @ViewBuilder var left: Left
    @ViewBuilder var right: Right

    var body: some View {
        ZStack {
            HStack(spacing: 6) {
                HStack(spacing: 0) { left }
                    .frame(minWidth: 44, alignment: .leading)
                Spacer(minLength: 0)
                HStack(spacing: 0) { right }
                    .frame(minWidth: 44, alignment: .trailing)
            }
            Text(title)
                .font(SelahFont.display(.headline))
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("selah.navbar.title")
        }
        .padding(.horizontal, SelahSpacing.navbarInline)
        .padding(.bottom, SelahSpacing.navbarBottom)
        .frame(minHeight: SelahSpacing.navbarMinHeight)
        .frame(maxWidth: .infinity)
        .background(SelahColors.background.opacity(0.82))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("selah.navbar")
    }
}

struct SelahHeaderIconButton: View {
    let systemName: String
    let label: String
    var identifier: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.body.weight(.semibold))
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier ?? label)
    }
}
