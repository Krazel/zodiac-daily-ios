import SwiftUI
import ZodiacDailyCore

/// Owner-approved final visual implementation of the C2 Saved empty and populated states.
struct SavedView: View {
    @EnvironmentObject private var model: AppModel
    let onViewToday: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        ZodiacMasthead(compact: true)

                        Text("Your Saved Cards")
                            .font(.system(.largeTitle, design: .serif, weight: .medium))
                            .foregroundStyle(ZodiacPalette.text)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        if model.savedCards.isEmpty {
                            emptyState
                        } else {
                            populatedState
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 34)
                    .frame(maxWidth: 650)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await model.reloadSavedCards()
                }
            }
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

    private var populatedState: some View {
        VStack(spacing: 18) {
            Text(collectionSummary)
                .font(.title3)
                .foregroundStyle(ZodiacPalette.lavender)
                .accessibilityLabel(collectionSummary)

            LazyVStack(spacing: 18) {
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
        }
    }

    private var emptyState: some View {
        VStack(spacing: 22) {
            Text("⌁")
                .font(.title)
                .foregroundStyle(ZodiacPalette.gold)
                .accessibilityHidden(true)

            EmptyCardBack(sign: model.selectedSign)
                .frame(maxWidth: 270)
                .aspectRatio(0.72, contentMode: .fit)
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text("No Cards Yet")
                    .font(.system(.title, design: .serif, weight: .medium))
                    .foregroundStyle(ZodiacPalette.text)
                    .accessibilityAddTraits(.isHeader)

                Text("Save today’s card to begin your collection.")
                    .font(.body)
                    .foregroundStyle(ZodiacPalette.mutedText)
                    .multilineTextAlignment(.center)
            }

            Button(action: onViewToday) {
                Text("VIEW TODAY’S CARD")
                    .font(.headline)
                    .tracking(2.2)
                    .frame(maxWidth: 310, minHeight: 54)
            }
            .buttonStyle(.plain)
            .foregroundStyle(ZodiacPalette.gold)
            .background(ZodiacPalette.cardNavy.opacity(0.78), in: Capsule())
            .overlay {
                Capsule().stroke(ZodiacPalette.gold, lineWidth: 1.2)
            }
            .contentShape(Capsule())
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
                        .frame(height: 170)
                    details
                        .padding(.horizontal, 24)
                        .padding(.vertical, 22)
                }
            } else {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        artwork
                            .frame(width: geometry.size.width * 0.52, height: 205)
                        details
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, minHeight: 205)
                    }
                }
                .frame(height: 205)
            }
        }
        .background {
            LinearGradient(
                colors: [ZodiacPalette.cardNavy, ZodiacPalette.midnight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.19), lineWidth: 3)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .inset(by: 7)
                .stroke(ZodiacPalette.gold, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.72), radius: 12, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(card.horoscope.sign.displayName), \(formattedDate), \(card.horoscope.headline)"
        )
    }

    private var artwork: some View {
        CelestialArtwork(sign: card.horoscope.sign)
            .overlay(alignment: .topLeading) {
                Text(card.horoscope.sign.symbol)
                    .font(.system(size: 42, weight: .ultraLight))
                    .foregroundStyle(ZodiacPalette.gold)
                    .padding(22)
                    .accessibilityHidden(true)
            }
            .clipped()
    }

    private var details: some View {
        VStack(spacing: 10) {
            Text(card.horoscope.sign.displayName.uppercased())
                .font(.system(.title2, design: .serif, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(ZodiacPalette.text)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(formattedDate.uppercased())
                .font(.caption.weight(.medium))
                .tracking(2.8)
                .foregroundStyle(ZodiacPalette.lavender)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            CelestialDivider(width: 95)

            Text(card.horoscope.headline)
                .font(.system(.title3, design: .serif, weight: .medium))
                .foregroundStyle(ZodiacPalette.text)
                .multilineTextAlignment(.center)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                .fixedSize(horizontal: false, vertical: true)

            Text("⌁")
                .font(.title2)
                .foregroundStyle(ZodiacPalette.gold)
                .accessibilityHidden(true)
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
            LinearGradient(
                colors: [ZodiacPalette.cardNavy, ZodiacPalette.midnight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Canvas { context, size in
                let points: [CGPoint] = [
                    CGPoint(x: 0.18, y: 0.18), CGPoint(x: 0.31, y: 0.29),
                    CGPoint(x: 0.52, y: 0.17), CGPoint(x: 0.72, y: 0.33),
                    CGPoint(x: 0.83, y: 0.21), CGPoint(x: 0.24, y: 0.66),
                    CGPoint(x: 0.67, y: 0.73), CGPoint(x: 0.79, y: 0.58)
                ]
                for (index, point) in points.enumerated() {
                    let radius: CGFloat = index.isMultiple(of: 3) ? 1.7 : 0.9
                    let rect = CGRect(
                        x: point.x * size.width - radius,
                        y: point.y * size.height - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(ZodiacPalette.paleGold.opacity(0.7)))
                }
            }

            VStack(spacing: 24) {
                Image(systemName: "sparkle")
                Text(sign?.symbol ?? "✦")
                    .font(.system(size: 54, weight: .ultraLight))
                Image(systemName: "bookmark")
                    .font(.title)
                    .foregroundStyle(ZodiacPalette.lavender)
            }
            .foregroundStyle(ZodiacPalette.gold)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.20), lineWidth: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .inset(by: 10)
                .stroke(ZodiacPalette.gold, lineWidth: 1.2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .inset(by: 15)
                .stroke(ZodiacPalette.gold.opacity(0.62), lineWidth: 0.7)
        }
        .shadow(color: .black.opacity(0.72), radius: 16, y: 10)
    }
}

/// PROVISIONAL detail wrapper. It reuses the approved card object, but its
/// surrounding hierarchy remains intentionally unfixed until a complete detail
/// reference is approved. Do not derive final detail layout from this view.
private struct SavedCardDetailView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    let card: SavedCard

    var body: some View {
        ZStack {
            MidnightBackground()
            ScrollView {
                VStack(spacing: 20) {
                    Text(card.horoscope.day.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(ZodiacPalette.lavender)
                    DailyCardView(horoscope: card.horoscope)
                    Button("Remove from Saved", role: .destructive) {
                        Task {
                            await model.removeSavedCard(id: card.id)
                            if !model.savedCards.contains(where: { $0.id == card.id }) {
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(20)
                .frame(maxWidth: 650)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(card.horoscope.sign.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
