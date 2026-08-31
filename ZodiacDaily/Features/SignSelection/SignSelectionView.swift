import SwiftUI
import ZodiacDailyCore

/// Measured implementation candidate for the approved C2 sign-selection reference.
struct SignSelectionView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale

    let requiresSelection: Bool
    @State private var pendingSign: ZodiacSign?

    private var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 2 : 3
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground()

                AdaptiveVerticalScrollView {
                    VStack(spacing: 0) {
                        selectionMasthead
                            .padding(.bottom, 29)

                        VStack(spacing: 10) {
                            Text(
                                requiresSelection
                                    ? appLocalized("Choose Your Sign", locale: locale)
                                    : appLocalized("Change Your Sign", locale: locale)
                            )
                                .font(ZodiacTypography.editorial(30))
                                .foregroundStyle(ZodiacPalette.text)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .accessibilityAddTraits(.isHeader)

                            Text(appLocalized("Your daily card will be written for this sign.", locale: locale))
                                .font(.system(size: 16))
                                .foregroundStyle(ZodiacPalette.mutedText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 24)

                        LazyVGrid(columns: columns, spacing: 13) {
                            ForEach(ZodiacSign.allCases, id: \.self) { sign in
                                SignChoiceCard(
                                    sign: sign,
                                    isSelected: pendingSign == sign,
                                    usesAccessibleHeight: dynamicTypeSize.isAccessibilitySize
                                ) {
                                    select(sign)
                                }
                            }
                        }
                        .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? 354 : 330)
                        .padding(.bottom, 28)

                        if requiresSelection {
                            Button(action: confirmSelection) {
                                HStack(spacing: 16) {
                                    Text("✦")
                                        .accessibilityHidden(true)
                                    Text(appLocalized("CONTINUE", locale: locale))
                                        .frame(maxWidth: .infinity)
                                    Text("✦")
                                        .accessibilityHidden(true)
                                }
                                .font(ZodiacTypography.interface(15, weight: .semibold))
                                .tracking(2.2)
                                .frame(width: 283, height: 49)
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
                            .accessibilityHint(
                                appLocalized("Confirms your selected zodiac sign", locale: locale)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 5)
                    .padding(.bottom, 24)
                    .frame(maxWidth: 430)
                    .frame(maxWidth: .infinity)
                }
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
                    .accessibilityLabel(
                        appLocalized("Close sign selection", locale: locale)
                    )
                }
            }
        }
        .interactiveDismissDisabled(requiresSelection)
        .onAppear {
            #if DEBUG
            if AppModel.visualQAState == .signSelection {
                pendingSign = .pisces
            } else if pendingSign == nil {
                pendingSign = model.selectedSign
            }
            #else
            if pendingSign == nil {
                pendingSign = model.selectedSign
            }
            #endif
        }
    }

    private func confirmSelection() {
        guard let pendingSign else { return }
        model.select(pendingSign)
    }

    private func select(_ sign: ZodiacSign) {
        pendingSign = sign
        guard !requiresSelection else { return }

        model.select(sign)
        dismiss()
    }

    private var selectionMasthead: some View {
        VStack(spacing: 4) {
            HStack(spacing: 11) {
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.42))
                    .frame(width: 34, height: 0.75)
                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(ZodiacPalette.gold)
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.42))
                    .frame(width: 34, height: 0.75)
            }
            .accessibilityHidden(true)

            Text("ZODIAC DAILY")
                .font(ZodiacTypography.editorial(21))
                .tracking(1.3)
                .foregroundStyle(ZodiacPalette.paleGold)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct SignChoiceCard: View {
    @Environment(\.locale) private var locale
    let sign: ZodiacSign
    let isSelected: Bool
    let usesAccessibleHeight: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Text(sign.symbol)
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundStyle(ZodiacPalette.gold)
                    .minimumScaleFactor(0.7)

                Text(sign.localizedDisplayName(locale: locale).uppercased(with: locale))
                    .font(ZodiacTypography.interface(10.5, weight: .semibold))
                    .tracking(0.45)
                    .foregroundStyle(ZodiacPalette.text)
                    .minimumScaleFactor(0.58)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: usesAccessibleHeight ? 136 : 114)
            .background {
                LinearGradient(
                    colors: [
                        ZodiacPalette.cardNavy.opacity(0.96),
                        ZodiacPalette.midnight.opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        isSelected ? ZodiacPalette.paleGold : Color.white.opacity(0.20),
                        lineWidth: isSelected ? 2.4 : 2.2
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .inset(by: 5.5)
                    .stroke(ZodiacPalette.gold.opacity(0.92), lineWidth: 0.75)
            }
            .overlay { SignCardOrnaments() }
            .shadow(
                color: isSelected ? ZodiacPalette.gold.opacity(0.85) : .black.opacity(0.72),
                radius: isSelected ? 6 : 5,
                y: 3
            )
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(sign.localizedDisplayName(locale: locale))
        .accessibilityValue(
            isSelected
                ? appLocalized("Selected", locale: locale)
                : appLocalized("Not selected", locale: locale)
        )
        .accessibilityHint(
            appLocalized("Selects this sign for your daily card", locale: locale)
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Native line work matching the four celestial corner ornaments in the approved cards.
private struct SignCardOrnaments: View {
    var body: some View {
        Canvas { context, size in
            let inset: CGFloat = 9
            let corners = [
                CGPoint(x: inset, y: inset),
                CGPoint(x: size.width - inset, y: inset),
                CGPoint(x: inset, y: size.height - inset),
                CGPoint(x: size.width - inset, y: size.height - inset)
            ]

            for corner in corners {
                var star = Path()
                star.move(to: CGPoint(x: corner.x - 5, y: corner.y))
                star.addLine(to: CGPoint(x: corner.x + 5, y: corner.y))
                star.move(to: CGPoint(x: corner.x, y: corner.y - 7))
                star.addLine(to: CGPoint(x: corner.x, y: corner.y + 7))
                star.move(to: CGPoint(x: corner.x - 3.5, y: corner.y - 3.5))
                star.addLine(to: CGPoint(x: corner.x + 3.5, y: corner.y + 3.5))
                star.move(to: CGPoint(x: corner.x + 3.5, y: corner.y - 3.5))
                star.addLine(to: CGPoint(x: corner.x - 3.5, y: corner.y + 3.5))
                context.stroke(star, with: .color(ZodiacPalette.gold), lineWidth: 0.55)
            }

            let bracketInset: CGFloat = 16
            let length: CGFloat = 7
            var brackets = Path()
            brackets.move(to: CGPoint(x: bracketInset, y: bracketInset + length))
            brackets.addLine(to: CGPoint(x: bracketInset, y: bracketInset))
            brackets.addLine(to: CGPoint(x: bracketInset + length, y: bracketInset))
            brackets.move(to: CGPoint(x: size.width - bracketInset - length, y: bracketInset))
            brackets.addLine(to: CGPoint(x: size.width - bracketInset, y: bracketInset))
            brackets.addLine(to: CGPoint(x: size.width - bracketInset, y: bracketInset + length))
            brackets.move(to: CGPoint(x: bracketInset, y: size.height - bracketInset - length))
            brackets.addLine(to: CGPoint(x: bracketInset, y: size.height - bracketInset))
            brackets.addLine(to: CGPoint(x: bracketInset + length, y: size.height - bracketInset))
            brackets.move(to: CGPoint(x: size.width - bracketInset - length, y: size.height - bracketInset))
            brackets.addLine(to: CGPoint(x: size.width - bracketInset, y: size.height - bracketInset))
            brackets.addLine(to: CGPoint(x: size.width - bracketInset, y: size.height - bracketInset - length))
            context.stroke(
                brackets,
                with: .color(ZodiacPalette.gold.opacity(0.72)),
                lineWidth: 0.55
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
