import SwiftUI
import ZodiacDailyCore

struct DailyCardView: View {
    @Environment(\.locale) private var locale
    let horoscope: DailyHoroscope
    var maxWidth: CGFloat = 328
    var artworkHeight: CGFloat = 296
    var contentSpacing: CGFloat = -7
    var headlineSize: CGFloat = 30
    var readingBottomPadding: CGFloat = 37
    var readingStackSpacing: CGFloat = 6
    var symbolSize: CGFloat = 54
    var symbolTopPadding: CGFloat = 25
    var fixedHeight: CGFloat?
    var showsTurnCue = false

    var body: some View {
        fittedFrontContent(cardHeight: fixedHeight ?? 478)
        .frame(maxWidth: maxWidth)
        .frame(height: fixedHeight, alignment: .top)
        .background {
            LinearGradient(
                colors: [ZodiacPalette.cardNavy, ZodiacPalette.deepIndigo.opacity(0.85), ZodiacPalette.midnight],
                startPoint: .top,
                endPoint: .bottom
            )

            Image("CelestialBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.11)
                .blendMode(.screen)
                .accessibilityHidden(true)
        }
        .c5bCardChrome()
        .overlay(alignment: .bottom) {
            if showsTurnCue {
                ZStack(alignment: .bottom) {
                    Image(systemName: "sparkle")
                        .font(.body)
                        .foregroundStyle(ZodiacPalette.gold)
                        .padding(.bottom, 4)

                    VStack(spacing: 1) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .light))
                            .foregroundStyle(ZodiacPalette.gold)

                        Text(appLocalized("TAP FOR MORE", locale: locale))
                            .font(.system(size: 9.5, weight: .semibold))
                            .tracking(2.1)
                            .foregroundStyle(ZodiacPalette.lavender)
                    }
                    .padding(.bottom, 24)
                }
                .accessibilityHidden(true)
            } else {
                Image(systemName: "sparkle")
                    .font(.body)
                    .foregroundStyle(ZodiacPalette.gold)
                    .padding(.bottom, 14)
                    .accessibilityHidden(true)
            }
        }
        .shadow(color: .black.opacity(0.75), radius: 18, y: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(horoscope.sign.localizedDisplayName(locale: locale)), \(horoscope.headline). \(horoscope.reading)"
        )
    }

    private var readingLabel: String {
        let interfaceIsSpanish = locale.identifier.lowercased().hasPrefix("es")

        if interfaceIsSpanish && horoscope.language == .english {
            return appLocalized("TODAY’S READING · ENGLISH FALLBACK", locale: locale)
        }
        if !interfaceIsSpanish && horoscope.language == .spanish {
            return appLocalized("TODAY’S READING · SPANISH", locale: locale)
        }
        return appLocalized("TODAY’S READING", locale: locale)
    }

    /// C6 treats the illustration and reading as one composed card. Artwork
    /// fills the complete face, a progressive ink wash creates a deliberate
    /// reading zone, and ViewThatFits protects readable type before using the
    /// compact 16.5 pt escape hatch on short devices or exceptional copy.
    private func fittedFrontContent(cardHeight: CGFloat) -> some View {
        ZStack(alignment: .top) {
            CelestialArtwork(sign: horoscope.sign)
                .frame(height: cardHeight)

            LinearGradient(
                stops: [
                    .init(color: ZodiacPalette.midnight.opacity(0.04), location: 0),
                    .init(color: ZodiacPalette.midnight.opacity(0.12), location: 0.34),
                    .init(color: ZodiacPalette.cardNavy.opacity(0.74), location: 0.56),
                    .init(color: ZodiacPalette.midnight.opacity(0.98), location: 0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                signIdentity
                    .padding(.top, max(24, cardHeight * 0.055))

                Spacer(minLength: max(24, cardHeight * 0.12))

                ViewThatFits(in: .vertical) {
                    readingPanel(headlineSize: 30, readingSize: 19, spacing: 7, bottomPadding: 62)
                    readingPanel(headlineSize: 28, readingSize: 18, spacing: 6, bottomPadding: 60)
                    readingPanel(headlineSize: 26, readingSize: 17, spacing: 5, bottomPadding: 58)
                    readingPanel(headlineSize: 24, readingSize: 16.5, spacing: 4, bottomPadding: 56)
                }
            }
            .frame(height: cardHeight)
        }
    }

    private var signIdentity: some View {
        VStack(spacing: 3) {
            Text(horoscope.sign.symbol)
                .font(.system(size: symbolSize, weight: .ultraLight))
                .foregroundStyle(ZodiacPalette.gold)

            Text(horoscope.sign.localizedDisplayName(locale: locale).uppercased(with: locale))
                .font(.system(size: 10.5, weight: .semibold))
                .tracking(3.1)
                .foregroundStyle(ZodiacPalette.lavender)
                .lineLimit(1)
        }
        .accessibilityHidden(true)
    }

    private func readingPanel(
        headlineSize: CGFloat,
        readingSize: CGFloat,
        spacing: CGFloat,
        bottomPadding: CGFloat
    ) -> some View {
        VStack(spacing: spacing) {
            Text(readingLabel)
                .font(.system(size: 10.5, weight: .semibold))
                .tracking(3.6)
                .foregroundStyle(ZodiacPalette.lavender)
                .lineLimit(1)

            HStack(spacing: 11) {
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.45))
                    .frame(maxWidth: 56, maxHeight: 1)
                Text("✦")
                    .font(.caption2)
                    .foregroundStyle(ZodiacPalette.gold)
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.45))
                    .frame(maxWidth: 56, maxHeight: 1)
            }
            .accessibilityHidden(true)

            Text(horoscope.headline)
                .font(.custom("Didot", size: headlineSize, relativeTo: .largeTitle))
                .foregroundStyle(ZodiacPalette.text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("∿")
                .font(.system(size: 16, weight: .light, design: .serif))
                .foregroundStyle(ZodiacPalette.gold)
                .accessibilityHidden(true)

            Text(horoscope.reading)
                .font(.system(size: readingSize))
                .foregroundStyle(ZodiacPalette.text.opacity(0.98))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, bottomPadding)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// The physical collectible card used by Today and Saved detail. Both routes
/// share the approved frame, fitting behavior, structured reverse, and turn.
struct FlippableDailyCard: View {
    let horoscope: DailyHoroscope
    let width: CGFloat
    let height: CGFloat
    let artworkHeight: CGFloat

    private let cornerRadius: CGFloat = C5BCardGeometry.outerCornerRadius

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale
    @State private var isShowingBack: Bool
    @State private var isAnimating = false

    init(
        horoscope: DailyHoroscope,
        initiallyShowingBack: Bool = false,
        width: CGFloat = 328,
        height: CGFloat = 478,
        artworkHeight: CGFloat = 296
    ) {
        self.horoscope = horoscope
        self.width = width
        self.height = height
        self.artworkHeight = artworkHeight
        _isShowingBack = State(initialValue: initiallyShowingBack)
    }

    var body: some View {
        Button(action: turnCard) {
            ZStack {
                DailyCardView(
                    horoscope: horoscope,
                    maxWidth: width,
                    artworkHeight: artworkHeight,
                    contentSpacing: -92,
                    readingBottomPadding: 54,
                    fixedHeight: height,
                    showsTurnCue: true
                )
                    .frame(width: width, height: height)
                    .opacity(isShowingBack ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(isShowingBack ? -180 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.65
                    )
                    .allowsHitTesting(!isShowingBack)
                    .accessibilityHidden(isShowingBack)

                DailyCardBackView(horoscope: horoscope)
                    .frame(width: width, height: height)
                    .opacity(isShowingBack ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isShowingBack ? 0 : 180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.65
                    )
                    .allowsHitTesting(isShowingBack)
                    .accessibilityHidden(!isShowingBack)
            }
            .frame(width: width, height: height)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isAnimating)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(horoscope.sign.localizedDisplayName(locale: locale)) \(appLocalized("daily card", locale: locale))"
        )
        .accessibilityValue(isShowingBack ? backAccessibilityValue : frontAccessibilityValue)
        .accessibilityHint(
            isShowingBack
                ? appLocalized("Double-tap to return to the illustrated reading", locale: locale)
                : appLocalized("Double-tap to reveal the deeper reading", locale: locale)
        )
        .onChange(of: horoscope.archiveKey) { _ in
            isShowingBack = false
            isAnimating = false
        }
    }

    private var frontAccessibilityValue: String {
        "\(appLocalized("Front", locale: locale)). \(horoscope.headline). \(horoscope.reading)"
    }

    private var backAccessibilityValue: String {
        let details = horoscope.details
        guard details.hasProviderData,
              let love = details.loveScore,
              let career = details.careerScore,
              let money = details.moneyScore,
              let health = details.healthScore,
              let luckyNumber = details.luckyNumber,
              let luckyColor = details.luckyColor,
              let moonSign = details.moonSign,
              let moonPhase = details.moonPhase else {
            return "\(appLocalized("Back", locale: locale)). "
                + "\(horoscope.sign.localizedDisplayName(locale: locale)) "
                + "\(appLocalized("essence", locale: locale)): \(details.signEssence)"
        }
        return "\(appLocalized("Back", locale: locale)). "
            + "\(appLocalized("Today's focus", locale: locale)): \(details.focus). "
            + "\(appLocalized("Keywords", locale: locale)): \(details.keywords.joined(separator: ", ")). "
            + "\(appLocalized("Scores", locale: locale)). "
            + "\(appLocalized("Love", locale: locale)) \(love), "
            + "\(appLocalized("career", locale: locale)) \(career), "
            + "\(appLocalized("money", locale: locale)) \(money), "
            + "\(appLocalized("health", locale: locale)) \(health). "
            + "\(appLocalized("Lucky number", locale: locale)) \(luckyNumber), "
            + "\(appLocalized("lucky color", locale: locale)) \(luckyColor). "
            + "\(appLocalized("Moon in", locale: locale)) \(moonSign), \(moonPhase). "
            + "\(horoscope.sign.localizedDisplayName(locale: locale)) "
            + "\(appLocalized("essence", locale: locale)): "
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
    @Environment(\.locale) private var locale

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

            VStack(spacing: 4) {
                VStack(spacing: 1) {
                    Text(horoscope.sign.symbol)
                        .font(.system(size: 36, weight: .ultraLight))
                        .foregroundStyle(ZodiacPalette.gold)

                    Text(horoscope.sign.localizedDisplayName(locale: locale).uppercased(with: locale))
                        .font(.system(size: 9.5, weight: .semibold))
                        .tracking(2.8)
                        .foregroundStyle(ZodiacPalette.gold)
                        .lineLimit(1)
                }

                Text(appLocalized("DEEPER READING", locale: locale))
                    .font(.custom("Didot", size: 14.5, relativeTo: .headline))
                    .tracking(2.8)
                    .foregroundStyle(ZodiacPalette.lavender)

                ornamentalDivider

                if details.hasProviderData,
                   let loveScore = details.loveScore,
                   let careerScore = details.careerScore,
                   let moneyScore = details.moneyScore,
                   let healthScore = details.healthScore,
                   let luckyColor = details.luckyColor,
                   let luckyNumber = details.luckyNumber,
                   let moonSign = details.moonSign,
                   let moonPhase = details.moonPhase {
                    providerContent(
                        loveScore: loveScore,
                        careerScore: careerScore,
                        moneyScore: moneyScore,
                        healthScore: healthScore,
                        luckyColor: luckyColor,
                        luckyNumber: luckyNumber,
                        moonSign: moonSign,
                        moonPhase: moonPhase
                    )
                } else {
                    offlineContent
                }

                Spacer(minLength: 1)

                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(ZodiacPalette.gold)

                Text(appLocalized("TAP TO TURN THE CARD", locale: locale))
                    .font(.system(size: 9.5, weight: .semibold))
                    .tracking(2.0)
                    .foregroundStyle(ZodiacPalette.lavender)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 21)
            .padding(.top, 18)
            .padding(.bottom, 14)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .c5bCardChrome()
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

    private var sectionDivider: some View {
        HStack(spacing: 5) {
            Rectangle()
                .fill(ZodiacPalette.gold.opacity(0.38))
                .frame(height: 0.6)
            Text("✦")
                .font(.system(size: 5))
                .foregroundStyle(ZodiacPalette.gold.opacity(0.82))
            Rectangle()
                .fill(ZodiacPalette.gold.opacity(0.38))
                .frame(height: 0.6)
        }
        .accessibilityHidden(true)
    }

    private func providerContent(
        loveScore: Int,
        careerScore: Int,
        moneyScore: Int,
        healthScore: Int,
        luckyColor: String,
        luckyNumber: Int,
        moonSign: String,
        moonPhase: String
    ) -> some View {
        Group {
            detailText(appLocalized("TODAY'S FOCUS", locale: locale), value: details.focus.uppercased(), size: 19)
            detailText(appLocalized("KEYWORDS", locale: locale), value: details.keywords.joined(separator: " · ").uppercased(), size: 13.5)
            sectionDivider

            Text(appLocalized("DAILY SCORES", locale: locale))
                .font(.system(size: 10, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(ZodiacPalette.gold)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                spacing: 4
            ) {
                scoreCell(appLocalized("LOVE", locale: locale), value: loveScore)
                scoreCell(appLocalized("CAREER", locale: locale), value: careerScore)
                scoreCell(appLocalized("MONEY", locale: locale), value: moneyScore)
                scoreCell(appLocalized("HEALTH", locale: locale), value: healthScore)
            }
            .overlay {
                ZStack {
                    Rectangle()
                        .fill(ZodiacPalette.gold.opacity(0.42))
                        .frame(width: 0.75)
                    Rectangle()
                        .fill(ZodiacPalette.gold.opacity(0.32))
                        .frame(height: 0.65)
                }
            }

            sectionDivider

            HStack(spacing: 0) {
                luckyDetail(appLocalized("LUCKY NUMBER", locale: locale), value: String(luckyNumber))
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.38))
                    .frame(width: 0.75, height: 28)
                luckyDetail(appLocalized("LUCKY COLOR", locale: locale), value: luckyColor.uppercased())
            }

            sectionDivider
            detailText(appLocalized("MOON", locale: locale), value: "\(moonSign.uppercased()) · \(moonPhase.uppercased())", size: 13.5)
            essenceSection
        }
    }

    private var offlineContent: some View {
        Group {
            detailText(
                "\(horoscope.sign.localizedDisplayName(locale: locale).uppercased(with: locale)) "
                    + appLocalized("ESSENCE", locale: locale),
                value: details.signEssence,
                size: 18
            )
            sectionDivider
            Text(
                appLocalized(
                    "Your complete daily reading is on the front of this card.",
                    locale: locale
                )
            )
                .font(.custom("Didot", size: 15, relativeTo: .body))
                .foregroundStyle(ZodiacPalette.text.opacity(0.96))
                .multilineTextAlignment(.center)
                .padding(.vertical, 28)
        }
    }

    private var essenceSection: some View {
        VStack(spacing: 2) {
            Text(
                "\(horoscope.sign.localizedDisplayName(locale: locale).uppercased(with: locale)) "
                    + appLocalized("ESSENCE", locale: locale)
            )
                .font(.system(size: 9.5, weight: .semibold))
                .tracking(2.1)
                .foregroundStyle(ZodiacPalette.gold)

            Text(details.signEssence)
                .font(.custom("Didot", size: 14, relativeTo: .subheadline))
                .foregroundStyle(ZodiacPalette.paleGold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
    }

    private func detailText(_ title: String, value: String, size: CGFloat) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9.5, weight: .semibold))
                .tracking(2.2)
                .foregroundStyle(ZodiacPalette.gold)
            Text(value)
                .font(.custom("Didot", size: size, relativeTo: .caption))
                .foregroundStyle(ZodiacPalette.paleGold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    private func scoreCell(_ title: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.8)
                .foregroundStyle(ZodiacPalette.gold)
            Text(String(value))
                .font(.custom("Didot", size: 22, relativeTo: .title3))
                .foregroundStyle(ZodiacPalette.paleGold)
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(title.capitalized(with: locale)) \(appLocalized("score", locale: locale)) "
                + "\(value) \(appLocalized("out of 100", locale: locale))"
        )
    }

    private func luckyDetail(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 8.5, weight: .semibold))
                .tracking(1.6)
                .foregroundStyle(ZodiacPalette.gold)
            Text(value)
                .font(.custom("Didot", size: 18, relativeTo: .headline))
                .foregroundStyle(ZodiacPalette.paleGold)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

private enum C5BCardGeometry {
    static let outerCornerRadius: CGFloat = 14
    static let outerStrokeWidth: CGFloat = 1
    static let innerInset: CGFloat = 8
    static let innerCornerRadius: CGFloat = 8
    static let motifInset: CGFloat = 10
}

private extension View {
    func c5bCardChrome() -> some View {
        clipShape(
            RoundedRectangle(
                cornerRadius: C5BCardGeometry.outerCornerRadius,
                style: .continuous
            )
        )
        .overlay { C5BCardFrameOverlay() }
    }
}

/// The approved B border is one native drawing shared by both physical faces:
/// a warm-gold outer line, an inset hairline, and four mirrored engraved
/// crescent/star corners. It replaces the gray rim and bracket ornaments.
private struct C5BCardFrameOverlay: View {
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Canvas { context, size in
            let outerHalf = C5BCardGeometry.outerStrokeWidth / 2
            let outerRect = CGRect(
                x: outerHalf,
                y: outerHalf,
                width: max(0, size.width - C5BCardGeometry.outerStrokeWidth),
                height: max(0, size.height - C5BCardGeometry.outerStrokeWidth)
            )
            let outer = Path(
                roundedRect: outerRect,
                cornerRadius: C5BCardGeometry.outerCornerRadius
            )
            context.stroke(
                outer,
                with: .color(ZodiacPalette.gold.opacity(0.96)),
                lineWidth: C5BCardGeometry.outerStrokeWidth
            )

            let hairline = max(1 / max(displayScale, 1), 0.33)
            let innerRect = outerRect.insetBy(
                dx: C5BCardGeometry.innerInset,
                dy: C5BCardGeometry.innerInset
            )
            let inner = Path(
                roundedRect: innerRect,
                cornerRadius: C5BCardGeometry.innerCornerRadius
            )
            context.stroke(
                inner,
                with: .color(ZodiacPalette.gold.opacity(0.58)),
                lineWidth: hairline
            )

            drawCornerMotifs(in: &context, size: size)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawCornerMotifs(in context: inout GraphicsContext, size: CGSize) {
        let inset = C5BCardGeometry.motifInset
        let placements: [(CGPoint, CGFloat, CGFloat)] = [
            (CGPoint(x: inset, y: inset), 1, 1),
            (CGPoint(x: size.width - inset, y: inset), -1, 1),
            (CGPoint(x: inset, y: size.height - inset), 1, -1),
            (CGPoint(x: size.width - inset, y: size.height - inset), -1, -1)
        ]

        for (anchor, scaleX, scaleY) in placements {
            let transform = CGAffineTransform(
                a: scaleX,
                b: 0,
                c: 0,
                d: scaleY,
                tx: anchor.x,
                ty: anchor.y
            )
            drawCorner(in: &context, transform: transform)
        }
    }

    private func drawCorner(in context: inout GraphicsContext, transform: CGAffineTransform) {
        let gold = Color(red: 0.839, green: 0.639, blue: 0.400).opacity(0.88)

        var orbitalLines = Path()
        orbitalLines.addArc(
            center: .zero,
            radius: 18,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        orbitalLines.addArc(
            center: .zero,
            radius: 23,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        context.stroke(
            orbitalLines.applying(transform),
            with: .color(gold.opacity(0.62)),
            lineWidth: 0.55
        )

        var crescent = Path()
        crescent.addArc(
            center: CGPoint(x: 9, y: 9),
            radius: 5.5,
            startAngle: .degrees(-78),
            endAngle: .degrees(78),
            clockwise: false
        )
        crescent.addArc(
            center: CGPoint(x: 11.5, y: 9),
            radius: 4.2,
            startAngle: .degrees(78),
            endAngle: .degrees(-78),
            clockwise: true
        )
        crescent.closeSubpath()
        context.stroke(
            crescent.applying(transform),
            with: .color(gold),
            lineWidth: 0.75
        )

        var star = Path()
        let starCenter = CGPoint(x: 19.5, y: 4.5)
        star.move(to: CGPoint(x: starCenter.x, y: starCenter.y - 3.5))
        star.addLine(to: CGPoint(x: starCenter.x + 1.15, y: starCenter.y - 1.1))
        star.addLine(to: CGPoint(x: starCenter.x + 3.5, y: starCenter.y))
        star.addLine(to: CGPoint(x: starCenter.x + 1.15, y: starCenter.y + 1.1))
        star.addLine(to: CGPoint(x: starCenter.x, y: starCenter.y + 3.5))
        star.addLine(to: CGPoint(x: starCenter.x - 1.15, y: starCenter.y + 1.1))
        star.addLine(to: CGPoint(x: starCenter.x - 3.5, y: starCenter.y))
        star.addLine(to: CGPoint(x: starCenter.x - 1.15, y: starCenter.y - 1.1))
        star.closeSubpath()
        context.fill(star.applying(transform), with: .color(gold))

        for point in [CGPoint(x: 4, y: 20), CGPoint(x: 13, y: 18), CGPoint(x: 20, y: 13)] {
            let dot = Path(ellipseIn: CGRect(x: point.x - 0.8, y: point.y - 0.8, width: 1.6, height: 1.6))
            context.fill(dot.applying(transform), with: .color(gold.opacity(0.82)))
        }
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
