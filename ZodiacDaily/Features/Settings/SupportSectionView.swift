import StoreKit
import SwiftUI

/// StoreKit-backed measured candidate for the approved support panel.
struct SupportSectionView: View {
    @EnvironmentObject private var store: SupportStore
    @Environment(\.openURL) private var openURL
    @Environment(\.locale) private var locale
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
            Text(localized("support.title").uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(ZodiacPalette.settingsLavender)
                .padding(.leading, 12)
                .frame(minHeight: 17)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 7) {
                supporterHeader

                ForEach(Array(AppConfiguration.supporterProductIDs.enumerated()), id: \.offset) { index, productID in
                    supportOption(productID: productID, index: index)
                }

                renewalDisclosure

                if let message = store.statusMessage {
                    Text(localizedStatus(message))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(store.isSupporter ? ZodiacPalette.settingsText : ZodiacPalette.settingsLavender)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(localizedStatus(message))
                }

                restoreButton
                manageButton
            }
            .padding(10)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(ZodiacPalette.settingsGold.opacity(0.72), lineWidth: 0.8)
            }
        }
        .padding(.top, 5)
    }

    private var supporterHeader: some View {
        HStack(spacing: 14) {
            celestialIcon("sparkle", size: 43)

            Text(localized(store.isSupporter ? "support.header.active" : "support.header.inactive"))
            .font(.system(size: 14))
            .foregroundStyle(ZodiacPalette.settingsText)
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
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
                    .font(.custom("Didot", size: 14, relativeTo: .headline))
                    .foregroundStyle(ZodiacPalette.settingsText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 6)

                if isPurchasing {
                    ProgressView()
                        .tint(ZodiacPalette.settingsGold)
                } else {
                    Text(isActive ? localized("support.active") : displayPrice(for: product, index: index))
                        .font(
                            .custom(
                                "Didot",
                                size: isActive ? 12 : 14,
                                relativeTo: .subheadline
                            )
                        )
                        .tracking(isActive ? 1.2 : 0)
                        .foregroundStyle(ZodiacPalette.settingsGold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ZodiacPalette.settingsGold)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(rowBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        isActive ? ZodiacPalette.settingsGold : ZodiacPalette.settingsGold.opacity(0.58),
                        lineWidth: 0.7
                    )
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
            "\(tierTitle(at: index)), \(displayPrice(for: product, index: index))\(isActive ? ", \(localized("support.active"))" : "")"
        )
        .accessibilityHint(optionAccessibilityHint(product: product, isActive: isActive))
    }

    private var renewalDisclosure: some View {
        Text(localized("support.renewal_disclosure"))
            .font(.system(size: 12))
            .foregroundStyle(ZodiacPalette.settingsMuted)
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
                title: store.isRestoring ? localized("support.restoring") : localized("support.restore"),
                systemImage: "arrow.counterclockwise"
            )
        }
        .buttonStyle(.plain)
        .disabled(store.isRestoring || store.purchasingProductID != nil)
        .accessibilityHint(localized("support.hint.restore"))
    }

    private var manageButton: some View {
        Button {
            if #available(iOS 17.0, *) {
                showsManageSubscriptions = true
            } else if let subscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions") {
                openURL(subscriptionsURL)
            }
        } label: {
            actionRow(title: localized("support.manage"), systemImage: "person")
        }
        .buttonStyle(.plain)
        .accessibilityHint(localized("support.hint.manage"))
    }

    private func actionRow(title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            celestialIcon(systemImage, size: 31)

            Text(title)
                .font(.custom("Didot", size: 13.5, relativeTo: .headline))
                .foregroundStyle(ZodiacPalette.settingsText)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZodiacPalette.settingsGold)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 35)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(ZodiacPalette.settingsGold.opacity(0.58), lineWidth: 0.7)
        }
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func celestialIcon(_ systemName: String, size: CGFloat) -> some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.43, weight: .light))
            .foregroundStyle(ZodiacPalette.settingsGold)
            .frame(width: size, height: size)
            .overlay {
                Circle().stroke(ZodiacPalette.settingsGold.opacity(0.72), lineWidth: 0.7)
            }
            .accessibilityHidden(true)
    }

    private var panelBackground: some View {
        LinearGradient(
            colors: [ZodiacPalette.settingsPanel.opacity(0.92), ZodiacPalette.settingsDeep.opacity(0.70)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var rowBackground: some View {
        LinearGradient(
            colors: [ZodiacPalette.settingsDeep.opacity(0.62), ZodiacPalette.settingsPanel.opacity(0.60)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func tierTitle(at index: Int) -> String {
        switch index {
        case 0: return localized("support.tier.monthly")
        case 1: return localized("support.tier.kind")
        default: return localized("support.tier.generous")
        }
    }

    private func displayPrice(for product: Product?, index: Int) -> String {
        if let product {
            return String(format: localized("support.price_per_month_format"), product.displayPrice)
        }
        #if DEBUG
        if AppModel.visualQAState == .settings {
            return String(format: localized("support.price_per_month_format"), visualQAPrices[index])
        }
        #endif
        return localized("support.unavailable")
    }

    private func optionAccessibilityHint(product: Product?, isActive: Bool) -> String {
        if isActive { return localized("support.hint.current_level") }
        if !store.canMakePayments { return localized("support.hint.purchases_unavailable") }
        if product == nil { return localized("support.hint.reload_unavailable") }
        return localized("support.hint.starts_monthly")
    }

    private func localizedStatus(_ message: SupportStore.StatusMessage) -> String {
        switch message {
        case .purchasesUnavailable:
            return localized("support.status.purchases_unavailable")
        case .optionUnavailable:
            return localized("support.status.option_unavailable")
        case .verificationFailed:
            return localized("support.status.verification_failed")
        case .thankYou:
            return localized("support.status.thank_you")
        case .pending:
            return localized("support.status.pending")
        case .purchaseFailed:
            return localized("support.status.purchase_failed")
        case .restored:
            return localized("support.status.restored")
        case .noneFound:
            return localized("support.status.none_found")
        case .restoreFailed:
            return localized("support.status.restore_failed")
        case .configurationError:
            return localized("support.status.configuration_error")
        }
    }

    private func localized(_ key: String.LocalizationValue) -> String {
        String(localized: key, locale: locale)
    }
}
