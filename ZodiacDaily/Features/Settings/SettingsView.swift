import SwiftUI

/// Measured implementation candidate for the approved C3 Settings sheet.
struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showsSignSelection = false

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground()
                    .overlay(ZodiacPalette.settingsDeep.opacity(0.78))

                ScrollView {
                    VStack(spacing: 10) {
                        header
                        signSection
                        SupportSectionView()
                        rateSection
                        privacyAndTermsSection
                        aboutSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 11)
                    .padding(.bottom, 20)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showsSignSelection) {
            SignSelectionView(requiresSelection: false)
        }
    }

    @ViewBuilder
    private var header: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .trailing, spacing: 2) {
                doneButton
                settingsTitle
            }
        } else {
            ZStack(alignment: .trailing) {
                settingsTitle
                doneButton
            }
            .frame(minHeight: 44)
        }
    }

    private var settingsTitle: some View {
        HStack(spacing: 12) {
            Text("✦")
                .font(.system(size: 18, weight: .light))
                .accessibilityHidden(true)
            Text("Settings")
                .font(.custom("Didot", size: 29, relativeTo: .largeTitle))
                .foregroundStyle(ZodiacPalette.settingsText)
                .accessibilityAddTraits(.isHeader)
            Text("✦")
                .font(.system(size: 18, weight: .light))
                .accessibilityHidden(true)
        }
        .foregroundStyle(ZodiacPalette.settingsGold)
        .frame(maxWidth: .infinity)
    }

    private var doneButton: some View {
        Button("DONE") {
            dismiss()
        }
        .font(.system(size: 14, weight: .medium))
        .tracking(1.8)
        .foregroundStyle(ZodiacPalette.settingsGold)
        .frame(minWidth: 58, minHeight: 44)
    }

    private var signSection: some View {
        settingsSection(title: "Your Sign") {
            Button {
                showsSignSelection = true
            } label: {
                HStack(spacing: 14) {
                    Text(model.selectedSign?.symbol ?? "?")
                        .font(.system(size: 37, weight: .ultraLight))
                        .foregroundStyle(ZodiacPalette.settingsGold)
                        .frame(width: 46)
                        .accessibilityHidden(true)

                    Text(model.selectedSign?.displayName.uppercased() ?? "CHOOSE SIGN")
                        .font(.custom("Didot", size: 18, relativeTo: .title3))
                        .tracking(1.4)
                        .foregroundStyle(ZodiacPalette.settingsText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 6)

                    Text("Change Sign")
                        .font(.system(size: 14))
                        .foregroundStyle(ZodiacPalette.settingsGold)
                        .lineLimit(1)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ZodiacPalette.settingsGold)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, minHeight: 51)
                .background(panelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(ZodiacPalette.settingsGold.opacity(0.72), lineWidth: 0.8)
                }
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Your sign, \(model.selectedSign?.displayName ?? "not selected")")
            .accessibilityHint("Opens zodiac sign selection")
        }
    }

    private var rateSection: some View {
        settingsSection(title: "Rate Zodiac Daily") {
            Button {
                guard let url = AppConfiguration.writeReviewURL else { return }
                openURL(url)
            } label: {
                framedActionRow(title: "Rate Zodiac Daily", systemImage: "star", minHeight: 43)
            }
            .buttonStyle(.plain)
            .accessibilityHint(
                AppConfiguration.writeReviewURL == nil
                    ? "Available after the App Store release"
                    : "Opens the App Store review page"
            )
        }
    }

    private var privacyAndTermsSection: some View {
        settingsSection(title: "Privacy & Terms") {
            VStack(spacing: 0) {
                Button {
                    openURL(AppConfiguration.privacyURL)
                } label: {
                    settingsActionRowContent(title: "Privacy Policy", systemImage: "lock")
                }
                .buttonStyle(.plain)

                Rectangle()
                    .fill(ZodiacPalette.settingsGold.opacity(0.50))
                    .frame(height: 0.7)

                Button {
                    openURL(AppConfiguration.termsURL)
                } label: {
                    settingsActionRowContent(title: "Terms of Use", systemImage: "list.bullet.rectangle")
                }
                .buttonStyle(.plain)
            }
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(ZodiacPalette.settingsGold.opacity(0.72), lineWidth: 0.8)
            }
        }
    }

    private var aboutSection: some View {
        settingsSection(title: "About") {
            HStack(spacing: 14) {
                celestialIcon("sparkle")

                Text("Daily readings are for reflection and entertainment.")
                    .font(.system(size: 15))
                    .foregroundStyle(ZodiacPalette.settingsText)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(ZodiacPalette.settingsGold.opacity(0.72), lineWidth: 0.8)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .semibold))
                .tracking(2.8)
                .foregroundStyle(ZodiacPalette.settingsLavender)
                .padding(.leading, 12)
                .accessibilityAddTraits(.isHeader)

            content()
        }
    }

    private func framedActionRow(
        title: String,
        systemImage: String,
        minHeight: CGFloat
    ) -> some View {
        settingsActionRowContent(title: title, systemImage: systemImage, minHeight: minHeight)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(ZodiacPalette.settingsGold.opacity(0.72), lineWidth: 0.8)
            }
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func settingsActionRowContent(
        title: String,
        systemImage: String,
        minHeight: CGFloat = 37
    ) -> some View {
        HStack(spacing: 12) {
            celestialIcon(systemImage)

            Text(title)
                .font(.custom("Didot", size: 17, relativeTo: .headline))
                .foregroundStyle(ZodiacPalette.settingsText)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZodiacPalette.settingsGold)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: minHeight)
        .contentShape(Rectangle())
    }

    private func celestialIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 19, weight: .light))
            .foregroundStyle(ZodiacPalette.settingsGold)
            .frame(width: 31, height: 31)
            .overlay {
                Circle().stroke(ZodiacPalette.settingsGold.opacity(0.72), lineWidth: 0.7)
            }
            .accessibilityHidden(true)
    }

    private var panelBackground: some View {
        LinearGradient(
            colors: [ZodiacPalette.settingsPanel.opacity(0.90), ZodiacPalette.settingsDeep.opacity(0.68)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
