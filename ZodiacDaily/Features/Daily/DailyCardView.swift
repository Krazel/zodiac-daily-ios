import SwiftUI
import ZodiacDailyCore

struct DailyCardView: View {
    let horoscope: DailyHoroscope

    var body: some View {
        VStack(spacing: 0) {
            CelestialArtwork(sign: horoscope.sign)
                .frame(height: 280)
                .overlay(alignment: .top) {
                    Text(horoscope.sign.symbol)
                        .font(.system(size: 64, weight: .ultraLight))
                        .foregroundStyle(ZodiacPalette.gold)
                        .padding(.top, 30)
                        .accessibilityHidden(true)
                }

            VStack(spacing: 13) {
                Text("TODAY’S READING")
                    .font(.caption.weight(.medium))
                    .tracking(4)
                    .foregroundStyle(ZodiacPalette.lavender)

                HStack(spacing: 11) {
                    Rectangle()
                        .fill(ZodiacPalette.gold.opacity(0.45))
                        .frame(maxWidth: 60, maxHeight: 1)
                    Text("✦")
                        .foregroundStyle(ZodiacPalette.gold)
                    Rectangle()
                        .fill(ZodiacPalette.gold.opacity(0.45))
                        .frame(maxWidth: 60, maxHeight: 1)
                }
                .accessibilityHidden(true)

                Text(horoscope.headline)
                    .font(.system(.largeTitle, design: .serif, weight: .medium))
                    .foregroundStyle(ZodiacPalette.text)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("⌁")
                    .font(.title)
                    .foregroundStyle(ZodiacPalette.gold)
                    .accessibilityHidden(true)

                Text(horoscope.reading)
                    .font(.body)
                    .foregroundStyle(ZodiacPalette.text.opacity(0.94))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)
            .padding(.bottom, 42)
        }
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
        .overlay(alignment: .bottom) {
            HStack {
                Text("✦")
                Spacer()
                Text("✦")
                Spacer()
                Text("✦")
            }
            .font(.title2)
            .foregroundStyle(ZodiacPalette.gold)
            .padding(.horizontal, 18)
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

private struct CelestialArtwork: View {
    let sign: ZodiacSign

    private let stars: [CGPoint] = [
        CGPoint(x: 0.08, y: 0.12), CGPoint(x: 0.17, y: 0.31),
        CGPoint(x: 0.29, y: 0.18), CGPoint(x: 0.36, y: 0.41),
        CGPoint(x: 0.48, y: 0.24), CGPoint(x: 0.57, y: 0.37),
        CGPoint(x: 0.67, y: 0.16), CGPoint(x: 0.76, y: 0.34),
        CGPoint(x: 0.88, y: 0.22), CGPoint(x: 0.92, y: 0.49),
        CGPoint(x: 0.13, y: 0.53), CGPoint(x: 0.43, y: 0.55),
        CGPoint(x: 0.62, y: 0.51), CGPoint(x: 0.81, y: 0.59)
    ]

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
            [point(0.27, 0.68), point(0.34, 0.52), point(0.40, 0.61), point(0.49, 0.47), point(0.58, 0.58), point(0.69, 0.42), point(0.78, 0.49)]
        }
    }

    var body: some View {
        Canvas { context, size in
            let bounds = CGRect(origin: .zero, size: size)
            var background = Path()
            background.addRect(bounds)
            context.fill(
                background,
                with: .linearGradient(
                    Gradient(colors: [ZodiacPalette.midnight, ZodiacPalette.cardNavy]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: size.width, y: size.height)
                )
            )

            for (index, point) in stars.enumerated() {
                let center = CGPoint(x: point.x * size.width, y: point.y * size.height)
                let radius = index.isMultiple(of: 3) ? 1.6 : 0.8
                let starRect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                context.fill(Path(ellipseIn: starRect), with: .color(ZodiacPalette.paleGold.opacity(0.85)))
            }

            let points = constellation.map {
                CGPoint(
                    x: $0.x * size.width,
                    y: $0.y * size.height
                )
            }
            var connection = Path()
            if let first = points.first {
                connection.move(to: first)
                for point in points.dropFirst() {
                    connection.addLine(to: point)
                }
            }
            context.stroke(
                connection,
                with: .color(ZodiacPalette.gold.opacity(0.62)),
                style: StrokeStyle(lineWidth: 0.8, dash: [2.5, 3.5])
            )

            for point in points {
                context.fill(
                    Path(ellipseIn: CGRect(x: point.x - 2.4, y: point.y - 2.4, width: 4.8, height: 4.8)),
                    with: .color(ZodiacPalette.paleGold)
                )
            }

            for wave in 0..<5 {
                let y = size.height * (0.81 + CGFloat(wave) * 0.038)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addCurve(
                    to: CGPoint(x: size.width, y: y + 3),
                    control1: CGPoint(x: size.width * 0.28, y: y - 8),
                    control2: CGPoint(x: size.width * 0.69, y: y + 11)
                )
                context.stroke(path, with: .color(ZodiacPalette.lavender.opacity(0.22)), lineWidth: 1)
            }
        }
        .overlay(alignment: .bottomLeading) {
            ZStack {
                Circle()
                    .fill(ZodiacPalette.paleGold)
                Circle()
                    .fill(ZodiacPalette.cardNavy)
                    .offset(x: 8, y: -4)
            }
            .frame(width: 30, height: 30)
            .padding(.leading, 35)
            .padding(.bottom, 48)
        }
        .accessibilityHidden(true)
    }

    private func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }
}
