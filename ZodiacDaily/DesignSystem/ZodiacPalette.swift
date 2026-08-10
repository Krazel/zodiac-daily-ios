import SwiftUI

enum ZodiacPalette {
    static let midnight = Color(red: 0.012, green: 0.024, blue: 0.075)
    static let cardNavy = Color(red: 0.035, green: 0.058, blue: 0.145)
    static let deepIndigo = Color(red: 0.065, green: 0.070, blue: 0.165)
    static let gold = Color(red: 0.90, green: 0.66, blue: 0.34)
    static let paleGold = Color(red: 0.98, green: 0.88, blue: 0.70)
    static let lavender = Color(red: 0.70, green: 0.62, blue: 0.88)
    static let text = Color(red: 0.97, green: 0.95, blue: 0.91)
    static let panelBorder = Color(red: 0.55, green: 0.38, blue: 0.22)
    static let mutedText = Color(red: 0.75, green: 0.71, blue: 0.82)
}

struct MidnightBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Image("CelestialBackground")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [
                            ZodiacPalette.midnight.opacity(0.10),
                            .clear,
                            Color.black.opacity(0.18)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .ignoresSafeArea()
    }
}

struct ZodiacMasthead: View {
    var compact = false

    var body: some View {
        VStack(spacing: compact ? 5 : 9) {
            HStack(spacing: 11) {
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.42))
                    .frame(width: compact ? 34 : 42, height: 1)
                Image(systemName: "sparkle")
                    .font(compact ? .caption : .body)
                    .foregroundStyle(ZodiacPalette.gold)
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.42))
                    .frame(width: compact ? 34 : 42, height: 1)
            }
            .accessibilityHidden(true)

            Text("ZODIAC DAILY")
                .font(.custom("Didot", size: compact ? 22 : 28))
                .tracking(compact ? 2.2 : 3)
                .foregroundStyle(ZodiacPalette.paleGold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }
}

struct CelestialDivider: View {
    var width: CGFloat = 140

    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(ZodiacPalette.gold.opacity(0.42))
                .frame(maxWidth: width / 2, maxHeight: 1)
            Image(systemName: "sparkle")
                .font(.caption2)
                .foregroundStyle(ZodiacPalette.gold)
            Rectangle()
                .fill(ZodiacPalette.gold.opacity(0.42))
                .frame(maxWidth: width / 2, maxHeight: 1)
        }
        .frame(maxWidth: width)
        .accessibilityHidden(true)
    }
}

struct OrnateCardCorners: View {
    var inset: CGFloat = 18

    var body: some View {
        Canvas { context, size in
            let corners = [
                CGPoint(x: inset, y: inset),
                CGPoint(x: size.width - inset, y: inset),
                CGPoint(x: inset, y: size.height - inset),
                CGPoint(x: size.width - inset, y: size.height - inset)
            ]

            for corner in corners {
                var star = Path()
                star.move(to: CGPoint(x: corner.x - 9, y: corner.y))
                star.addLine(to: CGPoint(x: corner.x + 9, y: corner.y))
                star.move(to: CGPoint(x: corner.x, y: corner.y - 12))
                star.addLine(to: CGPoint(x: corner.x, y: corner.y + 12))
                star.move(to: CGPoint(x: corner.x - 6, y: corner.y - 6))
                star.addLine(to: CGPoint(x: corner.x + 6, y: corner.y + 6))
                star.move(to: CGPoint(x: corner.x + 6, y: corner.y - 6))
                star.addLine(to: CGPoint(x: corner.x - 6, y: corner.y + 6))
                context.stroke(
                    star,
                    with: .color(ZodiacPalette.gold),
                    lineWidth: 0.75
                )
            }

            let bracketInset = inset + 15
            let bracketLength: CGFloat = 13
            var brackets = Path()
            brackets.move(to: CGPoint(x: bracketInset, y: bracketInset + bracketLength))
            brackets.addLine(to: CGPoint(x: bracketInset, y: bracketInset))
            brackets.addLine(to: CGPoint(x: bracketInset + bracketLength, y: bracketInset))

            brackets.move(to: CGPoint(x: size.width - bracketInset - bracketLength, y: bracketInset))
            brackets.addLine(to: CGPoint(x: size.width - bracketInset, y: bracketInset))
            brackets.addLine(to: CGPoint(x: size.width - bracketInset, y: bracketInset + bracketLength))

            brackets.move(to: CGPoint(x: bracketInset, y: size.height - bracketInset - bracketLength))
            brackets.addLine(to: CGPoint(x: bracketInset, y: size.height - bracketInset))
            brackets.addLine(to: CGPoint(x: bracketInset + bracketLength, y: size.height - bracketInset))

            brackets.move(to: CGPoint(x: size.width - bracketInset - bracketLength, y: size.height - bracketInset))
            brackets.addLine(to: CGPoint(x: size.width - bracketInset, y: size.height - bracketInset))
            brackets.addLine(to: CGPoint(x: size.width - bracketInset, y: size.height - bracketInset - bracketLength))
            context.stroke(
                brackets,
                with: .color(ZodiacPalette.gold.opacity(0.72)),
                lineWidth: 0.75
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ZodiacSectionTitle: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.subheadline.weight(.semibold))
            .tracking(3.2)
            .foregroundStyle(ZodiacPalette.lavender)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

struct ZodiacPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                LinearGradient(
                    colors: [
                        ZodiacPalette.cardNavy.opacity(0.96),
                        ZodiacPalette.deepIndigo.opacity(0.72)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(ZodiacPalette.panelBorder, lineWidth: 1)
            }
    }
}
