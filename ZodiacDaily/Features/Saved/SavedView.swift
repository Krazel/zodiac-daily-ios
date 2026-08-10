import SwiftUI
import ZodiacDailyCore

/// Measured C2 Saved implementation candidate. The approved empty, populated, and detail
/// references are the visual specification for the regular-size-class layout.
struct SavedView: View {
    @EnvironmentObject private var model: AppModel
    let onViewToday: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground(dimming: 0.40)

                ScrollView {
                    VStack(spacing: 0) {
                        savedHeader

                        if model.savedCards.isEmpty {
                            emptyState
                        } else {
                            populatedState
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, model.savedCards.isEmpty ? 26 : 0)
                    .padding(.bottom, 34)
                    .frame(maxWidth: 650)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await model.reloadSavedCards()
                }
            }
            .navigationTitle("Saved")
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .bottom) {
                if let message = model.persistenceMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(ZodiacPalette.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(ZodiacPalette.deepIndigo, in: Capsule())
                        .overlay {
                            Capsule().stroke(ZodiacPalette.gold.opacity(0.55), lineWidth: 1)
                        }
                        .padding()
                        .accessibilityLabel("Saved cards error: \(message)")
                }
            }
        }
        .task {
            await model.reloadSavedCards()
        }
    }

    private var savedHeader: some View {
        VStack(spacing: 0) {
            ZodiacMasthead(compact: true)
                .offset(y: model.savedCards.isEmpty ? -11 : -3)
                .padding(.bottom, 5)

            Text("Your Saved Cards")
                .font(
                    .custom(
                        "Didot",
                        size: model.savedCards.isEmpty ? 35 : 33,
                        relativeTo: .largeTitle
                    )
                )
                .foregroundStyle(ZodiacPalette.text)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.78)
                .lineLimit(1)
                .padding(.top, 0)
                .offset(y: model.savedCards.isEmpty ? 0 : -3)
                .accessibilityAddTraits(.isHeader)

            if model.savedCards.isEmpty {
                Text("∿")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundStyle(ZodiacPalette.gold)
                    .padding(.top, 5)
                    .accessibilityHidden(true)
            } else {
                Text(collectionSummary)
                    .font(.system(size: 16, weight: .regular))
                    .tracking(0.45)
                    .foregroundStyle(ZodiacPalette.lavender)
                    .padding(.top, 3)
                    .offset(y: -3)
                    .accessibilityLabel(collectionSummary)
            }
        }
    }

    private var populatedState: some View {
        LazyVStack(spacing: 13) {
            ForEach(model.savedCards) { card in
                NavigationLink {
                    SavedCardDetailView(card: card)
                } label: {
                    SavedCardPreview(card: card)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button("Delete Card", role: .destructive) {
                        Task { await model.removeSavedCard(id: card.id) }
                    }
                }
                .accessibilityHint("Opens this saved card. Use the actions menu to delete it.")
                .accessibilityAction(named: "Delete Card") {
                    Task { await model.removeSavedCard(id: card.id) }
                }
            }
        }
        .padding(.top, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            EmptyCardBack(sign: model.selectedSign)
                .padding(.top, 6)
                .accessibilityHidden(true)

            Text("No Cards Yet")
                .font(.custom("Didot", size: 29, relativeTo: .title))
                .foregroundStyle(ZodiacPalette.text)
                .padding(.top, 20)
                .accessibilityAddTraits(.isHeader)

            Text("Save today’s card to begin your collection.")
                .font(.system(size: 15.5))
                .foregroundStyle(ZodiacPalette.mutedText)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Button(action: onViewToday) {
                Text("VIEW TODAY’S CARD")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(2.2)
                    .frame(width: 214, height: 38)
            }
            .buttonStyle(.plain)
            .foregroundStyle(ZodiacPalette.gold)
            .background(ZodiacPalette.cardNavy.opacity(0.48), in: Capsule())
            .overlay {
                Capsule().stroke(ZodiacPalette.gold, lineWidth: 1)
            }
            .contentShape(Capsule())
            .frame(minHeight: 44)
            .padding(.top, 21)
            .accessibilityHint("Switches to Today")
        }
    }

    private var collectionSummary: String {
        let count = model.savedCards.count
        return count == 1 ? "1 card in your collection" : "\(count) cards in your collection"
    }
}

private struct SavedCardPreview: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let card: SavedCard

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 0) {
                        artwork
                            .frame(height: 213)
                    details
                        .padding(.horizontal, 24)
                        .padding(.vertical, 22)
                }
            } else {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        artwork
                            .frame(width: geometry.size.width * 0.515, height: 213)

                        details
                            .padding(.horizontal, 10)
                            .padding(.vertical, 17)
                            .frame(maxWidth: .infinity, minHeight: 213)
                    }
                }
                .frame(height: 213)
            }
        }
        .background {
            LinearGradient(
                colors: [ZodiacPalette.cardNavy, ZodiacPalette.midnight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 2.5)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .inset(by: 6)
                .stroke(ZodiacPalette.gold, lineWidth: 0.9)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .inset(by: 10)
                .stroke(ZodiacPalette.gold.opacity(0.48), lineWidth: 0.55)
        }
        .overlay {
            OrnateCardCorners(inset: 17)
        }
        .shadow(color: .black.opacity(0.72), radius: 10, y: 7)
        .contentShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(card.horoscope.sign.displayName), \(formattedDate), \(card.horoscope.headline)"
        )
    }

    private var artwork: some View {
        CelestialArtwork(sign: card.horoscope.sign)
            .overlay(alignment: .top) {
                Text(card.horoscope.sign.symbol)
                    .font(.system(size: 39, weight: .ultraLight))
                    .foregroundStyle(ZodiacPalette.gold)
                    .padding(.top, 25)
                    .accessibilityHidden(true)
            }
            .overlay {
                LinearGradient(
                    colors: [.clear, ZodiacPalette.midnight.opacity(0.12)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .clipped()
    }

    private var details: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            Text(card.horoscope.sign.displayName.uppercased())
                .font(.custom("Didot", size: 20, relativeTo: .title2))
                .tracking(1.25)
                .foregroundStyle(ZodiacPalette.text)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(formattedDate.uppercased())
                .font(.system(size: 11, weight: .medium))
                .tracking(2.5)
                .foregroundStyle(ZodiacPalette.lavender)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.top, 8)

            CelestialDivider(width: 90)
                .padding(.top, 12)

            Text(card.horoscope.headline)
                .font(.custom("Didot", size: 21, relativeTo: .title2))
                .foregroundStyle(ZodiacPalette.text)
                .multilineTextAlignment(.center)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 13)

            Text("∿")
                .font(.system(size: 25, weight: .light, design: .serif))
                .foregroundStyle(ZodiacPalette.gold)
                .padding(.top, 8)
                .accessibilityHidden(true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var formattedDate: String {
        guard let date = card.horoscope.day.startDate(in: .current) else {
            return card.horoscope.day.rawValue
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .current
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
}

private struct EmptyCardBack: View {
    let sign: ZodiacSign?

    var body: some View {
        ZStack {
            Image("CelestialBackground")
                .resizable()
                .scaledToFill()

            LinearGradient(
                colors: [
                    ZodiacPalette.cardNavy.opacity(0.36),
                    ZodiacPalette.midnight.opacity(0.18),
                    ZodiacPalette.cardNavy.opacity(0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialConstellation()
                .padding(.horizontal, 35)
                .offset(y: -8)

            Text(sign?.symbol ?? "✦")
                .font(.system(size: 53, weight: .ultraLight))
                .foregroundStyle(ZodiacPalette.gold)
                .offset(y: -8)

            Image(systemName: "bookmark")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(ZodiacPalette.lavender)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 51)
        }
        .frame(width: 254, height: 378)
        .clipShape(RoundedRectangle(cornerRadius: 23, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .stroke(Color.white.opacity(0.24), lineWidth: 3)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .inset(by: 8)
                .stroke(ZodiacPalette.gold, lineWidth: 1.1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .inset(by: 13)
                .stroke(ZodiacPalette.gold.opacity(0.66), lineWidth: 0.6)
        }
        .overlay {
            OrnateCardCorners(inset: 27)
        }
        .shadow(color: .black.opacity(0.76), radius: 15, y: 10)
    }
}

private struct RadialConstellation: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let rayCount = 18

            for index in 0..<rayCount {
                let angle = (Double(index) / Double(rayCount)) * Double.pi * 2
                let startRadius: CGFloat = 38
                let endRadius: CGFloat = index.isMultiple(of: 2) ? 84 : 69
                let start = CGPoint(
                    x: center.x + CGFloat(cos(angle)) * startRadius,
                    y: center.y + CGFloat(sin(angle)) * startRadius
                )
                let end = CGPoint(
                    x: center.x + CGFloat(cos(angle)) * endRadius,
                    y: center.y + CGFloat(sin(angle)) * endRadius
                )
                var ray = Path()
                ray.move(to: start)
                ray.addLine(to: end)
                context.stroke(
                    ray,
                    with: .color(ZodiacPalette.gold.opacity(0.74)),
                    style: StrokeStyle(lineWidth: 0.85, dash: [1.2, 3.4])
                )
            }

            for angle in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 2) {
                let radius: CGFloat = 93
                let point = CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius,
                    y: center.y + CGFloat(sin(angle)) * radius
                )
                var star = Path()
                star.move(to: CGPoint(x: point.x - 8, y: point.y))
                star.addLine(to: CGPoint(x: point.x + 8, y: point.y))
                star.move(to: CGPoint(x: point.x, y: point.y - 8))
                star.addLine(to: CGPoint(x: point.x, y: point.y + 8))
                context.stroke(star, with: .color(ZodiacPalette.gold), lineWidth: 0.8)
            }
        }
        .accessibilityHidden(true)
    }
}

/// Measured implementation candidate for the approved C2 saved-card detail reference.
struct SavedCardDetailView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    let card: SavedCard

    var body: some View {
        ZStack {
            MidnightBackground(dimming: 0.45)

            VStack(spacing: 0) {
                detailHeader

                ScrollView {
                    VStack(spacing: 0) {
                        Text(formattedDate.uppercased())
                            .font(.system(size: 14, weight: .medium))
                            .tracking(3.8)
                            .foregroundStyle(ZodiacPalette.lavender)

                        CelestialDivider(width: 122)
                            .padding(.top, 10)

                        DailyCardView(
                            horoscope: card.horoscope,
                            maxWidth: 345,
                            artworkHeight: 351,
                            contentSpacing: -44,
                            headlineSize: 30,
                            readingBottomPadding: 46,
                            readingStackSpacing: 4,
                            symbolSize: 56,
                            symbolTopPadding: 27
                        )
                            .padding(.top, 18)

                        Button(role: .destructive) {
                            removeCard()
                        } label: {
                            Label("REMOVE FROM SAVED", systemImage: "trash")
                                .font(.system(size: 13, weight: .semibold))
                                .tracking(1.8)
                                .foregroundStyle(Color(red: 1.0, green: 0.27, blue: 0.24))
                                .frame(maxWidth: 286, minHeight: 43)
                        }
                        .buttonStyle(.plain)
                        .background(
                            ZodiacPalette.midnight.opacity(0.36),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 1.0, green: 0.27, blue: 0.24), lineWidth: 1.2)
                        }
                        .frame(minHeight: 44)
                        .padding(.top, 33)
                        .accessibilityHint("Deletes this card from your collection")

                        if let message = model.persistenceMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(ZodiacPalette.lavender)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 14)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 0)
                    .padding(.bottom, 42)
                    .frame(maxWidth: 650)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var detailHeader: some View {
        ZStack {
            Text("Saved Card")
                .font(.custom("Didot", size: 21, relativeTo: .title3))
                .foregroundStyle(ZodiacPalette.text)

            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 19, weight: .medium))
                        Text("Saved")
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(ZodiacPalette.gold)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("Back to Saved")

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 48)
    }

    private var formattedDate: String {
        guard let date = card.horoscope.day.startDate(in: .current) else {
            return card.horoscope.day.rawValue
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .current
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private func removeCard() {
        Task {
            await model.removeSavedCard(id: card.id)
            if !model.savedCards.contains(where: { $0.id == card.id }) {
                dismiss()
            }
        }
    }
}
