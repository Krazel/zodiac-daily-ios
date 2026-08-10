import SwiftUI
import ZodiacDailyCore

struct DailyCardView: View {
    let horoscope: DailyHoroscope
    var maxWidth: CGFloat = 328
    var artworkHeight: CGFloat = 316

    var body: some View {
        VStack(spacing: -22) {
            CelestialArtwork(sign: horoscope.sign)
                .frame(height: artworkHeight)
                .overlay(alignment: .top) {
                    Text(horoscope.sign.symbol)
                        .font(.system(size: 62, weight: .ultraLight))
                        .foregroundStyle(ZodiacPalette.gold)
                        .padding(.top, 16)
                        .accessibilityHidden(true)
                }

            VStack(spacing: 4) {
                Text("TODAY’S READING")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(4)
                    .foregroundStyle(ZodiacPalette.lavender)

                HStack(spacing: 11) {
                    Rectangle()
                        .fill(ZodiacPalette.gold.opacity(0.45))
                        .frame(maxWidth: 50, maxHeight: 1)
                    Text("✦")
                        .font(.caption2)
                        .foregroundStyle(ZodiacPalette.gold)
                    Rectangle()
                        .fill(ZodiacPalette.gold.opacity(0.45))
                        .frame(maxWidth: 50, maxHeight: 1)
                }
                .accessibilityHidden(true)

                Text(horoscope.headline)
                    .font(.custom("Didot", size: 33, relativeTo: .largeTitle))
                    .foregroundStyle(ZodiacPalette.text)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("∿")
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .foregroundStyle(ZodiacPalette.gold)
                    .accessibilityHidden(true)

                Text(horoscope.reading)
                    .font(.system(size: 13.5))
                    .foregroundStyle(ZodiacPalette.text.opacity(0.94))
                    .multilineTextAlignment(.center)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 38)
            .padding(.top, 0)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: maxWidth)
        .background {
            LinearGradient(
                colors: [ZodiacPalette.cardNavy, ZodiacPalette.deepIndigo.opacity(0.85), ZodiacPalette.midnight],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 3)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .inset(by: 10)
                .stroke(ZodiacPalette.gold, lineWidth: 1.2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .inset(by: 15)
                .stroke(ZodiacPalette.gold.opacity(0.65), lineWidth: 0.7)
        }
        .overlay {
            OrnateCardCorners()
        }
        .overlay(alignment: .bottom) {
            Image(systemName: "sparkle")
                .font(.body)
                .foregroundStyle(ZodiacPalette.gold)
                .padding(.bottom, 14)
                .accessibilityHidden(true)
        }
        .shadow(color: .black.opacity(0.75), radius: 18, y: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(horoscope.sign.displayName), \(horoscope.headline). \(horoscope.reading)"
        )
    }
}

/// Production artwork shared by Today, Saved previews, and Saved detail.
struct CelestialArtwork: View {
    let sign: ZodiacSign

    private var artworkName: String {
        switch sign {
        case .scorpio, .taurus, .virgo, .capricorn:
            return "CardLake"
        case .sagittarius, .aries, .leo:
            return "CardRoad"
        case .gemini, .cancer, .libra, .aquarius, .pisces:
            return "CardOcean"
        }
    }

    private var constellation: [CGPoint] {
        switch sign {
        case .aries:
            [point(0.24, 0.64), point(0.34, 0.52), point(0.46, 0.50), point(0.58, 0.43), point(0.72, 0.47)]
        case .taurus:
            [point(0.24, 0.55), point(0.36, 0.48), point(0.50, 0.54), point(0.62, 0.43), point(0.76, 0.36), point(0.66, 0.58)]
        case .gemini:
            [point(0.28, 0.42), point(0.36, 0.62), point(0.48, 0.47), point(0.58, 0.66), point(0.70, 0.48), point(0.78, 0.61)]
        case .cancer:
            [point(0.27, 0.51), point(0.40, 0.45), point(0.52, 0.57), point(0.65, 0.49), point(0.76, 0.61)]
        case .leo:
            [point(0.22, 0.62), point(0.34, 0.52), point(0.46, 0.43), point(0.58, 0.45), point(0.68, 0.36), point(0.79, 0.43)]
        case .virgo:
            [point(0.22, 0.44), point(0.34, 0.54), point(0.46, 0.46), point(0.57, 0.58), point(0.69, 0.49), point(0.79, 0.62)]
        case .libra:
            [point(0.25, 0.58), point(0.38, 0.48), point(0.50, 0.54), point(0.62, 0.44), point(0.76, 0.50)]
        case .scorpio:
            [point(0.23, 0.64), point(0.32, 0.53), point(0.42, 0.58), point(0.51, 0.45), point(0.61, 0.51), point(0.70, 0.39), point(0.80, 0.47)]
        case .sagittarius:
            [point(0.22, 0.65), point(0.34, 0.57), point(0.47, 0.52), point(0.60, 0.43), point(0.73, 0.36), point(0.66, 0.55)]
        case .capricorn:
            [point(0.24, 0.42), point(0.36, 0.51), point(0.48, 0.46), point(0.60, 0.57), point(0.72, 0.50), point(0.79, 0.63)]
        case .aquarius:
            [point(0.22, 0.49), point(0.34, 0.40), point(0.46, 0.55), point(0.58, 0.45), point(0.70, 0.58), point(0.79, 0.47)]
        case .pisces:
            [
                point(0.27, 0.69), point(0.30, 0.57), point(0.33, 0.44),
                point(0.35, 0.31), point(0.42, 0.59), point(0.54, 0.53),
                point(0.66, 0.47), point(0.76, 0.42), point(0.82, 0.35),
                point(0.85, 0.41), point(0.82, 0.47)
            ]
        }
    }

    private var connections: [(Int, Int)] {
        if sign == .pisces {
            return [
                (0, 1), (1, 2), (2, 3),
                (0, 4), (4, 5), (5, 6), (6, 7), (7, 8),
                (8, 9), (9, 10), (10, 7)
            ]
        }
        return Array(zip(constellation.indices, constellation.indices.dropFirst()))
    }

    var body: some View {
        ZStack {
            Image(artworkName)
                .resizable()
                .scaledToFill()

            LinearGradient(
                colors: [
                    ZodiacPalette.midnight.opacity(0.20),
                    .clear,
                    ZodiacPalette.midnight.opacity(0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { context, size in
                let points = constellation.map {
                    CGPoint(x: $0.x * size.width, y: $0.y * size.height)
                }
                var connection = Path()
                for edge in connections {
                    connection.move(to: points[edge.0])
                    connection.addLine(to: points[edge.1])
                }
                context.stroke(
                    connection,
                    with: .color(ZodiacPalette.gold.opacity(0.74)),
                    style: StrokeStyle(lineWidth: 0.55, dash: [1.5, 2.5])
                )

                for point in points {
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: point.x - 1.25,
                            y: point.y - 1.25,
                            width: 2.5,
                            height: 2.5
                        )),
                        with: .color(ZodiacPalette.paleGold)
                    )
                    var rays = Path()
                    rays.move(to: CGPoint(x: point.x - 4.5, y: point.y))
                    rays.addLine(to: CGPoint(x: point.x + 4.5, y: point.y))
                    rays.move(to: CGPoint(x: point.x, y: point.y - 4.5))
                    rays.addLine(to: CGPoint(x: point.x, y: point.y + 4.5))
                    context.stroke(
                        rays,
                        with: .color(ZodiacPalette.paleGold.opacity(0.72)),
                        lineWidth: 0.45
                    )
                }
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }

    private func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }
}
