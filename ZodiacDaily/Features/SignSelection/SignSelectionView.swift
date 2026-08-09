import SwiftUI
import ZodiacDailyCore

/// Owner-approved final visual implementation of the C2 sign-selection reference.
struct SignSelectionView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let requiresSelection: Bool
    @State private var pendingSign: ZodiacSign?

    private var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 2 : 3
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        ZodiacMasthead()

                        VStack(spacing: 8) {
                            Text(requiresSelection ? "Choose Your Sign" : "Change Your Sign")
                                .font(.system(.largeTitle, design: .serif, weight: .medium))
                                .foregroundStyle(ZodiacPalette.text)
                                .multilineTextAlignment(.center)
                                .accessibilityAddTraits(.isHeader)

                            Text("Your daily card will be written for this sign.")
                                .font(.body)
                                .foregroundStyle(ZodiacPalette.mutedText)
                                .multilineTextAlignment(.center)
                        }

                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(ZodiacSign.allCases, id: \.self) { sign in
                                SignChoiceCard(
                                    sign: sign,
                                    isSelected: pendingSign == sign
                                ) {
                                    pendingSign = sign
                                }
                            }
                        }

                        Button(action: confirmSelection) {
                            HStack(spacing: 20) {
                                Image(systemName: "sparkle")
                                Text(requiresSelection ? "CONTINUE" : "USE THIS SIGN")
                                    .frame(maxWidth: .infinity)
                                Image(systemName: "sparkle")
                            }
                            .font(.headline)
                            .tracking(3)
                            .frame(minHeight: 56)
                            .padding(.horizontal, 24)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(ZodiacPalette.gold)
                        .background(ZodiacPalette.cardNavy.opacity(0.78), in: Capsule())
                        .overlay {
                            Capsule().stroke(ZodiacPalette.gold, lineWidth: 1.2)
                        }
                        .contentShape(Capsule())
                        .disabled(pendingSign == nil)
                        .opacity(pendingSign == nil ? 0.48 : 1)
                        .accessibilityHint("Confirms your selected zodiac sign")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topTrailing) {
                if !requiresSelection {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .background(ZodiacPalette.cardNavy.opacity(0.88), in: Circle())
                            .overlay {
                                Circle().stroke(ZodiacPalette.gold.opacity(0.65), lineWidth: 1)
                            }
                    }
                    .foregroundStyle(ZodiacPalette.paleGold)
                    .padding(.top, 8)
                    .padding(.trailing, 12)
                    .accessibilityLabel("Close sign selection")
                }
            }
        }
        .interactiveDismissDisabled(requiresSelection)
        .onAppear {
            if pendingSign == nil {
                pendingSign = model.selectedSign
            }
        }
    }

    private func confirmSelection() {
        guard let pendingSign else { return }
        model.select(pendingSign)
        if !requiresSelection {
            dismiss()
        }
    }
}

private struct SignChoiceCard: View {
    let sign: ZodiacSign
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(sign.symbol)
                    .font(.system(size: 42, weight: .ultraLight))
                    .foregroundStyle(ZodiacPalette.gold)
                    .minimumScaleFactor(0.7)

                Text(sign.displayName.uppercased())
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .tracking(1.4)
                    .foregroundStyle(ZodiacPalette.text)
                    .minimumScaleFactor(0.68)
                    .lineLimit(1)
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: 128)
            .background {
                LinearGradient(
                    colors: [ZodiacPalette.cardNavy, ZodiacPalette.midnight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 3)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .inset(by: 6)
                    .stroke(ZodiacPalette.gold, lineWidth: isSelected ? 1.8 : 0.8)
            }
            .overlay(alignment: .topLeading) {
                Image(systemName: "sparkle")
                    .font(.caption2)
                    .foregroundStyle(ZodiacPalette.gold)
                    .padding(10)
                    .accessibilityHidden(true)
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "sparkle")
                    .font(.caption2)
                    .foregroundStyle(isSelected ? ZodiacPalette.paleGold : ZodiacPalette.gold)
                    .padding(10)
                    .accessibilityHidden(true)
            }
            .shadow(
                color: isSelected ? ZodiacPalette.gold.opacity(0.55) : .black.opacity(0.55),
                radius: isSelected ? 9 : 5,
                y: 4
            )
            .contentShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(sign.displayName)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Selects this sign for your daily card")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
