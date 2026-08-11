import SwiftUI

enum ZodiacPalette {
    // Measured from the approved C2/C3 screen references. Keep these values as
    // the shared source of truth so every screen renders the same ink palette.
    static let midnight = Color(red: 0.016, green: 0.035, blue: 0.086) // #040916
    static let backgroundWash = Color(red: 0.027, green: 0.059, blue: 0.133) // #070F22
    static let cardNavy = Color(red: 0.051, green: 0.075, blue: 0.157) // #0D1328
    static let deepIndigo = Color(red: 0.067, green: 0.078, blue: 0.165) // #11142A
    static let gold = Color(red: 0.839, green: 0.639, blue: 0.400) // #D6A366
    static let paleGold = Color(red: 0.941, green: 0.855, blue: 0.733) // #F0DABB
    static let lavender = Color(red: 0.612, green: 0.569, blue: 0.745) // #9C91BE
    static let text = Color(red: 0.929, green: 0.898, blue: 0.859) // #EDE5DB
    static let panelBorder = Color(red: 0.463, green: 0.345, blue: 0.235) // #76583C
    static let mutedText = Color(red: 0.714, green: 0.682, blue: 0.761) // #B6AEC2

    // The approved Settings sheet uses a deliberately brighter print palette
    // than the darker collectible-card screens.
    static let settingsGold = Color(red: 0.894, green: 0.706, blue: 0.435) // #E4B46F
    static let settingsText = Color(red: 0.973, green: 0.969, blue: 0.945) // #F8F7F1
    static let settingsLavender = Color(red: 0.635, green: 0.604, blue: 0.784) // #A29AC8
    static let settingsMuted = Color(red: 0.714, green: 0.690, blue: 0.808) // #B6B0CE
    static let settingsPanel = Color(red: 0.075, green: 0.106, blue: 0.169) // #131B2B
    static let settingsDeep = Color(red: 0.067, green: 0.094, blue: 0.157) // #111828
}

struct MidnightBackground: View {
    var dimming: Double = 0

    var body: some View {
        GeometryReader { geometry in
            Image("CelestialBackground")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(ZodiacPalette.backgroundWash.opacity(0.42))
                .overlay {
                    LinearGradient(
                        colors: [
                            ZodiacPalette.midnight.opacity(0.06),
                            .clear,
                            Color.black.opacity(0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .overlay(Color.black.opacity(dimming))
        }
        .ignoresSafeArea()
    }
}

struct ZodiacMasthead: View {
    var compact = false

    var body: some View {
        VStack(spacing: compact ? 4 : 9) {
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
                .font(.custom("Didot", size: compact ? 17 : 28))
                .tracking(compact ? 1.4 : 3)
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

/// Keeps a page completely stationary whenever its content fits in the
/// available height, while preserving an accessibility/small-screen escape
/// hatch when it genuinely overflows. The content exists only once, so local
/// interaction state (such as the face of a flipped card) is never reset by a
/// layout branch change.
struct AdaptiveVerticalScrollView<Content: View>: View {
    private let content: Content
    @State private var contentHeight: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { viewport in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    Color.clear
                        .frame(height: 0)
                        .id(AdaptiveScrollAnchor.top)

                    content
                        .frame(maxWidth: .infinity)
                        .background {
                            GeometryReader { measuredContent in
                                Color.clear.preference(
                                    key: AdaptiveContentHeightKey.self,
                                    value: measuredContent.size.height
                                )
                            }
                        }
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(contentHeight <= viewport.size.height + 0.5)
                .onAppear {
                    scrollToTop(using: scrollProxy)
                }
                .onPreferenceChange(AdaptiveContentHeightKey.self) { measuredHeight in
                    contentHeight = measuredHeight
                    if measuredHeight <= viewport.size.height + 0.5 {
                        scrollToTop(using: scrollProxy)
                    }
                }
            }
        }
    }

    private func scrollToTop(using proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            proxy.scrollTo(AdaptiveScrollAnchor.top, anchor: .top)
        }
    }
}

private enum AdaptiveScrollAnchor: Hashable {
    case top
}

private struct AdaptiveContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
