import SwiftUI
import ZodiacDailyCore

struct DailyCardView: View {
    let horoscope: DailyHoroscope
    var maxWidth: CGFloat = 328
    var artworkHeight: CGFloat = 296
    var contentSpacing: CGFloat = -7
    var headlineSize: CGFloat = 30
    var readingBottomPadding: CGFloat = 37
    var readingStackSpacing: CGFloat = 1
    var symbolSize: CGFloat = 54
    var symbolTopPadding: CGFloat = 25

    var body: some View {
        VStack(spacing: contentSpacing) {
            CelestialArtwork(sign: horoscope.sign)
                .frame(height: artworkHeight)
                .overlay(alignment: .top) {
                    Text(horoscope.sign.symbol)
                        .font(.system(size: symbolSize, weight: .ultraLight))
                        .foregroundStyle(ZodiacPalette.gold)
                        .padding(.top, symbolTopPadding)
                        .accessibilityHidden(true)
                }

            VStack(spacing: readingStackSpacing) {
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
                    .font(.custom("Didot", size: headlineSize, relativeTo: .largeTitle))
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
            .padding(.horizontal, 28)
            .padding(.top, 8)
            .padding(.bottom, readingBottomPadding)
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

/// A Today-only wrapper that keeps the approved collectible-card frame while
/// revealing a structured reverse. Saved detail continues to use DailyCardView
/// directly and is therefore unaffected by the interaction.
struct FlippableDailyCard: View {
    private enum Metrics {
        static let width: CGFloat = 328
        static let height: CGFloat = 478
        static let cornerRadius: CGFloat = 25
    }

    let horoscope: DailyHoroscope

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShowingBack: Bool
    @State private var isAnimating = false

    init(horoscope: DailyHoroscope, initiallyShowingBack: Bool = false) {
        self.horoscope = horoscope
        _isShowingBack = State(initialValue: initiallyShowingBack)
    }

    var body: some View {
        Button(action: turnCard) {
            ZStack {
                DailyCardView(horoscope: horoscope)
                    .frame(width: Metrics.width, height: Metrics.height)
                    .opacity(isShowingBack ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(isShowingBack ? -180 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.65
                    )
                    .allowsHitTesting(!isShowingBack)
                    .accessibilityHidden(isShowingBack)

                DailyCardBackView(horoscope: horoscope)
                    .frame(width: Metrics.width, height: Metrics.height)
                    .opacity(isShowingBack ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isShowingBack ? 0 : 180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.65
                    )
                    .allowsHitTesting(isShowingBack)
                    .accessibilityHidden(!isShowingBack)
            }
            .frame(width: Metrics.width, height: Metrics.height)
            .contentShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isAnimating)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(horoscope.sign.displayName) daily card")
        .accessibilityValue(isShowingBack ? backAccessibilityValue : frontAccessibilityValue)
        .accessibilityHint(
            isShowingBack
                ? "Double-tap to return to the illustrated reading"
                : "Double-tap to reveal the deeper reading"
        )
        .onChange(of: horoscope.archiveKey) { _ in
            isShowingBack = false
            isAnimating = false
        }
    }

    private var frontAccessibilityValue: String {
        "Front. \(horoscope.headline). \(horoscope.reading)"
    }

    private var backAccessibilityValue: String {
        let details = horoscope.details
        return "Back. Love: \(details.love) Work: \(details.work) "
            + "Well-being: \(details.wellBeing) Lucky number: \(details.luckyNumber). "
            + "Lucky color: \(details.luckyColor). \(horoscope.sign.displayName) essence: "
            + details.signEssence
    }

    private func turnCard() {
        guard !isAnimating else { return }

        if reduceMotion {
            withAnimation(.easeOut(duration: 0.12)) {
                isShowingBack.toggle()
            }
            return
        }

        isAnimating = true
        withAnimation(.easeInOut(duration: 0.46)) {
            isShowingBack.toggle()
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 470_000_000)
            isAnimating = false
        }
    }
}

private struct DailyCardBackView: View {
    let horoscope: DailyHoroscope

    private var details: DailyCardDetails { horoscope.details }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    ZodiacPalette.cardNavy,
                    ZodiacPalette.deepIndigo.opacity(0.90),
                    ZodiacPalette.midnight
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Text(horoscope.sign.symbol)
                .font(.system(size: 210, weight: .ultraLight))
                .foregroundStyle(ZodiacPalette.gold.opacity(0.035))
                .offset(y: 22)
                .accessibilityHidden(true)

            VStack(spacing: 7) {
                Text(horoscope.sign.symbol)
                    .font(.system(size: 31, weight: .ultraLight))
                    .foregroundStyle(ZodiacPalette.gold)

                Text("DEEPER READING")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(3.1)
                    .foregroundStyle(ZodiacPalette.lavender)

                ornamentalDivider

                guidanceSection("LOVE", text: details.love)
                guidanceSection("WORK", text: details.work)
                guidanceSection("WELL-BEING", text: details.wellBeing)

                HStack(spacing: 0) {
                    luckyDetail("LUCKY NUMBER", value: String(details.luckyNumber))

                    Rectangle()
                        .fill(ZodiacPalette.gold.opacity(0.38))
                        .frame(width: 0.75, height: 32)

                    luckyDetail("LUCKY COLOR", value: details.luckyColor.uppercased())
                }

                VStack(spacing: 2) {
                    Text("\(horoscope.sign.displayName.uppercased()) ESSENCE")
                        .font(.system(size: 8, weight: .semibold))
                        .tracking(2.2)
                        .foregroundStyle(ZodiacPalette.lavender)

                    Text(details.signEssence)
                        .font(.custom("Didot", size: 12, relativeTo: .caption))
                        .foregroundStyle(ZodiacPalette.paleGold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }

                HStack(spacing: 6) {
                    Image(systemName: "arrow.uturn.backward")
                    Text("TAP TO TURN THE CARD")
                }
                .font(.system(size: 7.5, weight: .medium))
                .tracking(1.7)
                .foregroundStyle(ZodiacPalette.gold.opacity(0.75))
                .padding(.top, 1)
                .accessibilityHidden(true)
            }
            .padding(.horizontal, 29)
            .padding(.top, 21)
            .padding(.bottom, 18)
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
        .overlay { OrnateCardCorners() }
        .shadow(color: .black.opacity(0.75), radius: 18, y: 12)
    }

    private var ornamentalDivider: some View {
        HStack(spacing: 9) {
            Rectangle()
                .fill(ZodiacPalette.gold.opacity(0.42))
                .frame(height: 0.75)
            Text("✦")
                .font(.caption2)
                .foregroundStyle(ZodiacPalette.gold)
            Rectangle()
                .fill(ZodiacPalette.gold.opacity(0.42))
                .frame(height: 0.75)
        }
        .accessibilityHidden(true)
    }

    private func guidanceSection(_ title: String, text: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 8, weight: .semibold))
                .tracking(2.4)
                .foregroundStyle(ZodiacPalette.lavender)

            Text(text)
                .font(.custom("Didot", size: 11.5, relativeTo: .caption))
                .foregroundStyle(ZodiacPalette.text.opacity(0.96))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity)
    }

    private func luckyDetail(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 7.5, weight: .semibold))
                .tracking(1.8)
                .foregroundStyle(ZodiacPalette.lavender)
            Text(value)
                .font(.custom("Didot", size: 14, relativeTo: .subheadline))
                .foregroundStyle(ZodiacPalette.paleGold)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
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
                    style: StrokeStyle(lineWidth: 0.7, dash: [1.5, 2.5])
                )

                for point in points {
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: point.x - 2,
                            y: point.y - 2,
                            width: 4,
                            height: 4
                        )),
                        with: .color(ZodiacPalette.paleGold)
                    )
                    var rays = Path()
                    rays.move(to: CGPoint(x: point.x - 5.5, y: point.y))
                    rays.addLine(to: CGPoint(x: point.x + 5.5, y: point.y))
                    rays.move(to: CGPoint(x: point.x, y: point.y - 5.5))
                    rays.addLine(to: CGPoint(x: point.x, y: point.y + 5.5))
                    context.stroke(
                        rays,
                        with: .color(ZodiacPalette.paleGold.opacity(0.72)),
                        lineWidth: 0.5
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
