import StoreKit
import SwiftUI

/// StoreKit-backed implementation of the owner-approved support panel.
struct SupportSectionView: View {
    @EnvironmentObject private var store: SupportStore
    @Environment(\.openURL) private var openURL
    @State private var showsManageSubscriptions = false

    #if DEBUG
    private let visualQAPrices = ["$0.99", "$2.99", "$4.99"]
    #endif

    var body: some View {
        subscriptionManagementContent
    }

    @ViewBuilder
    private var subscriptionManagementContent: some View {
        if #available(iOS 17.0, *) {
            content
                .manageSubscriptionsSheet(isPresented: $showsManageSubscriptions)
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("SUPPORT THE APP")
                .font(.system(size: 14, weight: .semibold))
                .tracking(2.8)
                .foregroundStyle(ZodiacPalette.lavender)
                .padding(.leading, 12)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 6) {
                supporterHeader

                ForEach(Array(AppConfiguration.supporterProductIDs.enumerated()), id: \.offset) { index, productID in
                    supportOption(productID: productID, index: index)
                }

                renewalDisclosure

                if let message = store.statusMessage {
                    Text(message)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(store.isSupporter ? ZodiacPalette.paleGold : ZodiacPalette.lavender)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(message)
                }

                restoreButton
                manageButton
            }
            .padding(7)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(ZodiacPalette.gold.opacity(0.72), lineWidth: 0.8)
            }
        }
    }

    private var supporterHeader: some View {
        HStack(spacing: 12) {
            celestialIcon("sparkle", size: 38)

            Text(
                store.isSupporter
                    ? "Thank you for supporting ongoing development and helping keep the app free for everyone."
                    : "Support ongoing development and keep the app free for everyone."
            )
            .font(.system(size: 14))
            .foregroundStyle(ZodiacPalette.text)
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 1)
        .accessibilityElement(children: .combine)
    }

    private func supportOption(productID: String, index: Int) -> some View {
        let product = store.products.first { $0.id == productID }
        let isActive = store.activeProductID == productID
        let isPurchasing = store.purchasingProductID == productID

        return Button {
            Task {
                if let product {
                    await store.purchase(product)
                } else {
                    await store.retryCatalog()
                }
            }
        } label: {
            HStack(spacing: 10) {
                celestialIcon("sparkle", size: 31)

                Text(tierTitle(at: index))
                    .font(.custom("Didot", size: 15, relativeTo: .headline))
                    .foregroundStyle(ZodiacPalette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 6)

                if isPurchasing {
                    ProgressView()
                        .tint(ZodiacPalette.gold)
                } else {
                    Text(isActive ? "ACTIVE" : displayPrice(for: product, index: index))
                        .font(
                            .custom(
                                "Didot",
                                size: isActive ? 12 : 14,
                                relativeTo: .subheadline
                            )
                            .weight(.medium)
                        )
                        .tracking(isActive ? 1.2 : 0)
                        .foregroundStyle(ZodiacPalette.gold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ZodiacPalette.gold)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(rowBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isActive ? ZodiacPalette.gold : ZodiacPalette.gold.opacity(0.58), lineWidth: 0.7)
            }
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(
            isActive
                || store.purchasingProductID != nil
                || store.isRestoring
                || !store.canMakePayments
                || store.catalogState == .idle
                || store.catalogState == .loading
        )
        .opacity(1)
        .accessibilityLabel(
            "\(tierTitle(at: index)), \(displayPrice(for: product, index: index))\(isActive ? ", active" : "")"
        )
        .accessibilityHint(optionAccessibilityHint(product: product, isActive: isActive))
    }

    private var renewalDisclosure: some View {
        Text("All levels include the same supporter status.\nSubscriptions renew automatically until cancelled.")
            .font(.system(size: 11.5))
            .foregroundStyle(ZodiacPalette.mutedText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 1)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var restoreButton: some View {
        Button {
            Task { await store.restorePurchases() }
        } label: {
            actionRow(
                title: store.isRestoring ? "Restoring…" : "Restore Purchases",
                systemImage: "arrow.counterclockwise"
            )
        }
        .buttonStyle(.plain)
        .disabled(store.isRestoring || store.purchasingProductID != nil)
        .accessibilityHint("Restores an existing supporter subscription")
    }

    private var manageButton: some View {
        Button {
            if #available(iOS 17.0, *) {
                showsManageSubscriptions = true
            } else if let subscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions") {
                openURL(subscriptionsURL)
            }
        } label: {
            actionRow(title: "Manage Subscription", systemImage: "person")
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens Apple subscription management")
    }

    private func actionRow(title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            celestialIcon(systemImage, size: 31)

            Text(title)
                .font(.custom("Didot", size: 15, relativeTo: .headline))
                .foregroundStyle(ZodiacPalette.text)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZodiacPalette.gold)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 35)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(ZodiacPalette.gold.opacity(0.58), lineWidth: 0.7)
        }
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func celestialIcon(_ systemName: String, size: CGFloat) -> some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.43, weight: .light))
            .foregroundStyle(ZodiacPalette.gold)
            .frame(width: size, height: size)
            .overlay {
                Circle().stroke(ZodiacPalette.gold.opacity(0.72), lineWidth: 0.7)
            }
            .accessibilityHidden(true)
    }

    private var panelBackground: some View {
        LinearGradient(
            colors: [ZodiacPalette.cardNavy.opacity(0.92), ZodiacPalette.deepIndigo.opacity(0.70)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var rowBackground: some View {
        LinearGradient(
            colors: [ZodiacPalette.deepIndigo.opacity(0.62), ZodiacPalette.cardNavy.opacity(0.60)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func tierTitle(at index: Int) -> String {
        switch index {
        case 0: return "Monthly Supporter"
        case 1: return "Kind Supporter"
        default: return "Generous Supporter"
        }
    }

    private func displayPrice(for product: Product?, index: Int) -> String {
        if let product {
            return "\(product.displayPrice) / month"
        }
        #if DEBUG
        if AppModel.visualQAState == .settings {
            return "\(visualQAPrices[index]) / month"
        }
        #endif
        return "Unavailable"
    }

    private func optionAccessibilityHint(product: Product?, isActive: Bool) -> String {
        if isActive { return "Current supporter level" }
        if !store.canMakePayments { return "Purchases are unavailable on this device" }
        if product == nil { return "Reloads temporarily unavailable support options" }
        return "Starts an auto-renewable monthly subscription"
    }
}
