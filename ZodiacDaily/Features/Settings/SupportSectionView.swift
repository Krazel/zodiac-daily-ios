import StoreKit
import SwiftUI

struct SupportSectionView: View {
    @EnvironmentObject private var store: SupportStore
    @Environment(\.openURL) private var openURL
    @State private var showsManageSubscriptions = false

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
        VStack(spacing: 12) {
            ZodiacSectionTitle(title: "Support the App")

            ZodiacPanel {
                VStack(spacing: 18) {
                    supporterHeader

                    Divider()
                        .overlay(ZodiacPalette.gold.opacity(0.28))

                    catalog

                    Text("Support is optional. Zodiac Daily stays fully usable for free. Subscriptions renew monthly until cancelled.")
                        .font(.footnote)
                        .foregroundStyle(ZodiacPalette.mutedText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if let message = store.statusMessage {
                        Text(message)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(store.isSupporter ? ZodiacPalette.paleGold : ZodiacPalette.lavender)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    supportActions
                    legalLinks
                }
            }
        }
    }

    private var supporterHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: store.isSupporter ? "sparkles" : "heart")
                .font(.title3)
                .foregroundStyle(ZodiacPalette.gold)
                .frame(width: 48, height: 48)
                .overlay {
                    Circle().stroke(ZodiacPalette.gold.opacity(0.75), lineWidth: 1)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(store.isSupporter ? "Active Supporter" : "Help Zodiac Daily Grow")
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundStyle(ZodiacPalette.text)

                Text(store.isSupporter
                     ? "Thank you. Your support helps with maintenance and future updates."
                     : "Choose any monthly level. Every level offers the same supporter status and our sincere thanks.")
                    .font(.subheadline)
                    .foregroundStyle(ZodiacPalette.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var catalog: some View {
        switch store.catalogState {
        case .idle, .loading:
            HStack(spacing: 10) {
                ProgressView()
                    .tint(ZodiacPalette.gold)
                Text("Loading support options…")
                    .foregroundStyle(ZodiacPalette.mutedText)
            }
            .frame(maxWidth: .infinity, minHeight: 52)

        case .available, .partial:
            VStack(spacing: 10) {
                ForEach(store.products, id: \.id) { product in
                    supportOption(product)
                }
                if store.catalogState == .partial {
                    Text("Some support options are temporarily unavailable.")
                        .font(.footnote)
                        .foregroundStyle(ZodiacPalette.mutedText)
                        .multilineTextAlignment(.center)
                }
            }

        case .restricted:
            unavailableCatalog(
                title: "Purchases Unavailable",
                detail: "Purchases are restricted on this device."
            )

        case .unavailable:
            VStack(spacing: 12) {
                unavailableCatalog(
                    title: "Support Options Unavailable",
                    detail: "No charge can be made. Check your connection and try again."
                )
                Button("Try Again") {
                    Task { await store.retryCatalog() }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ZodiacPalette.gold)
                .frame(minHeight: 44)
            }
        }
    }

    private func supportOption(_ product: Product) -> some View {
        let isActive = store.activeProductID == product.id
        let isPurchasing = store.purchasingProductID == product.id

        return Button {
            Task { await store.purchase(product) }
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(tierTitle(for: product.id))
                        .font(.headline)
                        .foregroundStyle(ZodiacPalette.text)
                    Text(isActive ? "Current monthly support" : "Monthly supporter")
                        .font(.caption)
                        .foregroundStyle(ZodiacPalette.mutedText)
                }
                Spacer(minLength: 8)
                if isPurchasing {
                    ProgressView()
                        .tint(ZodiacPalette.gold)
                } else {
                    Text(isActive ? "ACTIVE" : product.displayPrice)
                        .font(.subheadline.weight(.bold))
                        .tracking(isActive ? 1.2 : 0)
                        .foregroundStyle(ZodiacPalette.gold)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(ZodiacPalette.deepIndigo.opacity(0.66), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(isActive ? ZodiacPalette.gold : Color.white.opacity(0.16), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isActive || store.purchasingProductID != nil || store.isRestoring)
        .accessibilityLabel("\(tierTitle(for: product.id)), \(product.displayPrice) per month\(isActive ? ", active" : "")")
        .accessibilityHint(isActive ? "Current supporter level" : "Starts an auto-renewable monthly subscription")
    }

    private var supportActions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                restoreButton
                manageButton
            }
            VStack(spacing: 4) {
                restoreButton
                manageButton
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(ZodiacPalette.gold)
        .buttonStyle(.plain)
    }

    private var legalLinks: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 18) {
                legalButtons
            }
            VStack(spacing: 0) {
                legalButtons
            }
        }
        .frame(maxWidth: .infinity)
        .font(.footnote)
    }

    private var restoreButton: some View {
        Button {
            Task { await store.restorePurchases() }
        } label: {
            Label(store.isRestoring ? "Restoring…" : "Restore Purchases", systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .disabled(store.isRestoring || store.purchasingProductID != nil)
    }

    private var manageButton: some View {
        Button {
            if #available(iOS 17.0, *) {
                showsManageSubscriptions = true
            } else if let subscriptionsURL = URL(
                string: "https://apps.apple.com/account/subscriptions"
            ) {
                openURL(subscriptionsURL)
            }
        } label: {
            Label("Manage", systemImage: "slider.horizontal.3")
                .frame(maxWidth: .infinity, minHeight: 44)
        }
    }

    @ViewBuilder
    private var legalButtons: some View {
        legalButton("Privacy", url: AppConfiguration.privacyURL)
        legalButton("Terms", url: AppConfiguration.termsURL)
        legalButton("Support", url: AppConfiguration.supportURL)
    }

    private func legalButton(_ title: String, url: URL) -> some View {
        Button(title) { openURL(url) }
            .foregroundStyle(ZodiacPalette.lavender)
            .frame(minHeight: 44)
    }

    private func unavailableCatalog(title: String, detail: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(ZodiacPalette.text)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(ZodiacPalette.mutedText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 58)
    }

    private func tierTitle(for productID: String) -> String {
        switch productID {
        case AppConfiguration.supporterProductIDs[0]:
            return "Supporter"
        case AppConfiguration.supporterProductIDs[1]:
            return "Kind Supporter"
        case AppConfiguration.supporterProductIDs[2]:
            return "Generous Supporter"
        default:
            return "Monthly Supporter"
        }
    }
}
