import SwiftUI

/// Owner-approved final visual implementation of the C2 Settings/About sheet.
struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showsSignSelection = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [ZodiacPalette.deepIndigo, ZodiacPalette.cardNavy, ZodiacPalette.midnight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        header

                        VStack(spacing: 12) {
                            ZodiacSectionTitle(title: "Your Sign")
                            signPanel
                        }

                        VStack(spacing: 12) {
                            ZodiacSectionTitle(title: "Privacy")
                            informationPanel(
                                icon: "lock",
                                text: "Your sign and saved cards stay on this device."
                            )
                        }

                        SupportSectionView()

                        VStack(spacing: 12) {
                            ZodiacSectionTitle(title: "App Store")
                            reviewPanel
                        }

                        VStack(spacing: 12) {
                            ZodiacSectionTitle(title: "About")
                            informationPanel(
                                icon: "sparkle",
                                text: "Daily readings are for reflection and entertainment."
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 34)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(ZodiacPalette.cardNavy)
        .sheet(isPresented: $showsSignSelection) {
            SignSelectionView(requiresSelection: false)
        }
    }

    @ViewBuilder
    private var header: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .trailing, spacing: 4) {
                doneButton
                settingsTitle
            }
        } else {
            ZStack(alignment: .trailing) {
                settingsTitle
                doneButton
            }
        }
    }

    private var settingsTitle: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkle")
                .accessibilityHidden(true)
            Text("Settings")
                .font(.system(.largeTitle, design: .serif, weight: .medium))
                .foregroundStyle(ZodiacPalette.text)
                .accessibilityAddTraits(.isHeader)
            Image(systemName: "sparkle")
                .accessibilityHidden(true)
        }
        .foregroundStyle(ZodiacPalette.gold)
        .frame(maxWidth: .infinity)
    }

    private var doneButton: some View {
        Button("DONE") {
            dismiss()
        }
        .font(.subheadline.weight(.semibold))
        .tracking(1.8)
        .foregroundStyle(ZodiacPalette.gold)
        .frame(minWidth: 54, minHeight: 44)
    }

    private var signPanel: some View {
        Button {
            showsSignSelection = true
        } label: {
            ZodiacPanel {
                signPanelContent
                .frame(minHeight: 50)
            }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityLabel(accessibilitySignLabel)
        .accessibilityHint("Opens zodiac sign selection")
    }

    private var accessibilitySignLabel: String {
        ["Your sign", model.selectedSign?.displayName ?? "not selected"]
            .joined(separator: ", ")
    }

    @ViewBuilder
    private var signPanelContent: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 14) {
                signIdentity
                changeSignLabel
            }
        } else {
            HStack(spacing: 16) {
                signIdentity
                Spacer(minLength: 8)
                changeSignLabel
            }
        }
    }

    private var signIdentity: some View {
        HStack(spacing: 16) {
            Text(model.selectedSign?.symbol ?? "?")
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundStyle(ZodiacPalette.gold)
                .frame(width: 46)

            Text(model.selectedSign?.displayName.uppercased() ?? "CHOOSE SIGN")
                .font(.system(.title3, design: .serif, weight: .medium))
                .tracking(1.4)
                .foregroundStyle(ZodiacPalette.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var changeSignLabel: some View {
        HStack(spacing: 8) {
            Text("Change Sign")
                .font(.subheadline)
                .foregroundStyle(ZodiacPalette.gold)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(ZodiacPalette.gold)
        }
    }

    private func informationPanel(icon: String, text: String) -> some View {
        ZodiacPanel {
            HStack(spacing: 18) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(ZodiacPalette.gold)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Circle().stroke(ZodiacPalette.gold.opacity(0.75), lineWidth: 1)
                    }
                    .accessibilityHidden(true)

                Text(text)
                    .font(.body)
                    .foregroundStyle(ZodiacPalette.text)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minHeight: 54)
        }
        .accessibilityElement(children: .combine)
    }

    private var reviewPanel: some View {
        Button {
            guard let url = AppConfiguration.writeReviewURL else { return }
            openURL(url)
        } label: {
            ZodiacPanel {
                HStack(spacing: 18) {
                    Image(systemName: "star")
                        .font(.title3)
                        .foregroundStyle(ZodiacPalette.gold)
                        .frame(width: 48, height: 48)
                        .overlay {
                            Circle().stroke(ZodiacPalette.gold.opacity(0.75), lineWidth: 1)
                        }
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rate Zodiac Daily")
                            .font(.headline)
                            .foregroundStyle(ZodiacPalette.text)
                        Text(AppConfiguration.writeReviewURL == nil
                             ? "Available after the App Store release."
                             : "Share a review on the App Store.")
                            .font(.subheadline)
                            .foregroundStyle(ZodiacPalette.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(ZodiacPalette.gold)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: 54)
            }
        }
        .buttonStyle(.plain)
        .disabled(AppConfiguration.writeReviewURL == nil)
        .accessibilityHint(AppConfiguration.writeReviewURL == nil
                           ? "Available after release"
                           : "Opens the App Store review page")
    }
}
