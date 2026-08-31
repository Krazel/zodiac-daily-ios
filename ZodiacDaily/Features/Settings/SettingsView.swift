import SwiftUI

/// Measured implementation candidate for the approved C3 Settings sheet.
struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale
    @AppStorage(AppLanguage.storageKey) private var appLanguageRawValue = AppLanguage.english.rawValue
    @State private var showsSignSelection = false

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground()
                    .overlay(ZodiacPalette.settingsDeep.opacity(0.78))

                ScrollView {
                    LazyVStack(spacing: 10) {
                        header
                        signSection
                        languageSection
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
            Text(localized("common.settings"))
                .font(ZodiacTypography.editorial(29))
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
        Button(localized("common.done")) {
            dismiss()
        }
        .font(.system(size: 14, weight: .medium))
        .tracking(1.8)
        .foregroundStyle(ZodiacPalette.settingsGold)
        .frame(minWidth: 58, minHeight: 44)
    }

    private var signSection: some View {
        settingsSection(title: localized("settings.your_sign")) {
            Button {
                showsSignSelection = true
            } label: {
                HStack(spacing: 14) {
                    Text(model.selectedSign?.symbol ?? "?")
                        .font(.system(size: 37, weight: .ultraLight))
                        .foregroundStyle(ZodiacPalette.settingsGold)
                        .frame(width: 46)
                        .accessibilityHidden(true)

                    Text(
                        model.selectedSign?.localizedDisplayName(locale: locale).uppercased()
                            ?? localized("settings.choose_sign").uppercased()
                    )
                        .font(ZodiacTypography.interface(18, weight: .semibold))
                        .tracking(0.7)
                        .foregroundStyle(ZodiacPalette.settingsText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 6)

                    Text(localized("settings.change_sign"))
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
            .accessibilityLabel(
                String(
                    format: localized("settings.sign_accessibility_format"),
                    model.selectedSign?.localizedDisplayName(locale: locale)
                        ?? localized("settings.sign_not_selected")
                )
            )
            .accessibilityHint(localized("settings.sign_selection_hint"))
        }
    }

    private var languageSection: some View {
        settingsSection(title: localized("settings.language")) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(AppLanguage.allCases) { language in
                        languageButton(language)
                    }
                }
                .padding(7)

                Rectangle()
                    .fill(ZodiacPalette.settingsGold.opacity(0.42))
                    .frame(height: 0.7)

                Text(localized("settings.daily_content_language"))
                    .font(.system(size: 13))
                    .foregroundStyle(ZodiacPalette.settingsLavender)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(ZodiacPalette.settingsGold.opacity(0.72), lineWidth: 0.8)
            }
        }
    }

    private func languageButton(_ language: AppLanguage) -> some View {
        let isSelected = currentLanguage == language

        return Button {
            appLanguageRawValue = language.rawValue
        } label: {
            HStack(spacing: 9) {
                Spacer(minLength: 0)

                Text(language.displayName)
                    .font(ZodiacTypography.interface(16, weight: .semibold))
                    .foregroundStyle(isSelected ? ZodiacPalette.settingsGold : ZodiacPalette.settingsText)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ZodiacPalette.settingsGold)
                        .accessibilityHidden(true)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(
                isSelected
                    ? ZodiacPalette.settingsPanel.opacity(0.88)
                    : Color.clear,
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        isSelected ? ZodiacPalette.settingsGold : Color.clear,
                        lineWidth: 0.8
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var rateSection: some View {
        settingsSection(title: localized("settings.rate_section")) {
            Button {
                guard let url = AppConfiguration.writeReviewURL else { return }
                openURL(url)
            } label: {
                framedActionRow(title: localized("settings.rate_action"), systemImage: "star", minHeight: 43)
            }
            .buttonStyle(.plain)
            .accessibilityHint(
                AppConfiguration.writeReviewURL == nil
                    ? localized("settings.rate_unavailable_hint")
                    : localized("settings.rate_open_hint")
            )
        }
    }

    private var privacyAndTermsSection: some View {
        settingsSection(title: localized("settings.privacy_terms")) {
            VStack(spacing: 0) {
                Button {
                    openURL(AppConfiguration.privacyURL)
                } label: {
                    settingsActionRowContent(title: localized("settings.privacy_policy"), systemImage: "lock")
                }
                .buttonStyle(.plain)

                Rectangle()
                    .fill(ZodiacPalette.settingsGold.opacity(0.50))
                    .frame(height: 0.7)

                Button {
                    openURL(AppConfiguration.termsURL)
                } label: {
                    settingsActionRowContent(title: localized("settings.terms_of_use"), systemImage: "list.bullet.rectangle")
                }
                .buttonStyle(.plain)

                Rectangle()
                    .fill(ZodiacPalette.settingsGold.opacity(0.50))
                    .frame(height: 0.7)

                Button {
                    openURL(AppConfiguration.supportURL)
                } label: {
                    settingsActionRowContent(title: localized("settings.help_support"), systemImage: "questionmark")
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
        settingsSection(title: localized("settings.about")) {
            HStack(spacing: 14) {
                celestialIcon("sparkle")

                Text(localized("settings.entertainment_notice"))
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
                .font(.system(size: 12, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(ZodiacPalette.settingsLavender)
                .padding(.leading, 12)
                .frame(minHeight: 17)
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
                .font(ZodiacTypography.interface(14.5, weight: .medium))
                .foregroundStyle(ZodiacPalette.settingsText)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZodiacPalette.settingsGold)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 17)
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

    private var currentLanguage: AppLanguage {
        AppLanguage(rawValue: appLanguageRawValue) ?? .english
    }

    private func localized(_ key: String) -> String {
        appLocalized(key, locale: locale)
    }
}
