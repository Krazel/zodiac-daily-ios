import SwiftUI

/// Owner-approved final visual implementation of the C3 Settings sheet.
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
                    .overlay(ZodiacPalette.midnight.opacity(0.18))

                ScrollView {
                    VStack(spacing: 18) {
                        header
                        signSection
                        SupportSectionView()
                        rateSection
                        privacyAndTermsSection
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
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
            .frame(minHeight: 48)
        }
    }

    private var settingsTitle: some View {
        HStack(spacing: 12) {
            Text("✦")
                .font(.system(size: 18, weight: .light))
                .accessibilityHidden(true)
            Text("Settings")
                .font(.custom("Didot", size: 29, relativeTo: .largeTitle).weight(.medium))
                .foregroundStyle(ZodiacPalette.text)
                .accessibilityAddTraits(.isHeader)
            Text("✦")
                .font(.system(size: 18, weight: .light))
                .accessibilityHidden(true)
        }
        .foregroundStyle(ZodiacPalette.gold)
        .frame(maxWidth: .infinity)
    }

    private var doneButton: some View {
        Button("DONE") {
            dismiss()
        }
        .font(.system(size: 14, weight: .semibold))
        .tracking(1.8)
        .foregroundStyle(ZodiacPalette.gold)
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
                        .foregroundStyle(ZodiacPalette.gold)
                        .frame(width: 46)
                        .accessibilityHidden(true)

                    Text(model.selectedSign?.displayName.uppercased() ?? "CHOOSE SIGN")
                        .font(.custom("Didot", size: 18, relativeTo: .title3).weight(.medium))
                        .tracking(1.4)
                        .foregroundStyle(ZodiacPalette.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 6)

                    Text("Change Sign")
                        .font(.system(size: 14))
                        .foregroundStyle(ZodiacPalette.gold)
                        .lineLimit(1)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ZodiacPalette.gold)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(panelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(ZodiacPalette.gold.opacity(0.72), lineWidth: 0.8)
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
                framedActionRow(title: "Rate Zodiac Daily", systemImage: "star")
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
                    .fill(ZodiacPalette.gold.opacity(0.50))
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
                    .stroke(ZodiacPalette.gold.opacity(0.72), lineWidth: 0.8)
            }
        }
    }

    private var aboutSection: some View {
        settingsSection(title: "About") {
            HStack(spacing: 14) {
                celestialIcon("sparkle")

                Text("Daily readings are for reflection and entertainment.")
                    .font(.system(size: 15))
                    .foregroundStyle(ZodiacPalette.text)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(ZodiacPalette.gold.opacity(0.72), lineWidth: 0.8)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .semibold))
                .tracking(2.8)
                .foregroundStyle(ZodiacPalette.lavender)
                .padding(.leading, 12)
                .accessibilityAddTraits(.isHeader)

            content()
        }
    }

    private func framedActionRow(title: String, systemImage: String) -> some View {
        settingsActionRowContent(title: title, systemImage: systemImage)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(ZodiacPalette.gold.opacity(0.72), lineWidth: 0.8)
            }
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func settingsActionRowContent(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            celestialIcon(systemImage)

            Text(title)
                .font(.custom("Didot", size: 17, relativeTo: .headline).weight(.medium))
                .foregroundStyle(ZodiacPalette.text)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZodiacPalette.gold)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 58)
        .contentShape(Rectangle())
    }

    private func celestialIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 19, weight: .light))
            .foregroundStyle(ZodiacPalette.gold)
            .frame(width: 40, height: 40)
            .overlay {
                Circle().stroke(ZodiacPalette.gold.opacity(0.72), lineWidth: 0.7)
            }
            .accessibilityHidden(true)
    }

    private var panelBackground: some View {
        LinearGradient(
            colors: [ZodiacPalette.cardNavy.opacity(0.90), ZodiacPalette.deepIndigo.opacity(0.68)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
