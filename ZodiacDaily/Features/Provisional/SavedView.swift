import SwiftUI
import ZodiacDailyCore

/// PROVISIONAL internal implementation. Saved empty/populated layouts and
/// saved-card detail need their own complete images and owner approval.
struct SavedView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            Group {
                if model.savedCards.isEmpty {
                    ContentUnavailableView(
                        "No saved cards",
                        systemImage: "bookmark",
                        description: Text("Cards you save from Today will stay on this iPhone.")
                    )
                } else {
                    List {
                        ForEach(model.savedCards) { card in
                            NavigationLink {
                                SavedCardDetailView(card: card)
                            } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("\(card.horoscope.sign.symbol)  \(card.horoscope.sign.displayName)")
                                        .font(.headline)
                                        .foregroundStyle(ZodiacPalette.paleGold)
                                    Text(card.horoscope.headline)
                                        .font(.system(.body, design: .serif))
                                        .lineLimit(2)
                                    Text(card.horoscope.day.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 7)
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    Task { await model.removeSavedCard(id: card.id) }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(MidnightBackground())
            .navigationTitle("Saved")
            .overlay(alignment: .bottom) {
                if let message = model.persistenceMessage {
                    Text(message)
                        .font(.footnote)
                        .padding(12)
                        .background(.thinMaterial, in: Capsule())
                        .padding()
                }
            }
        }
        .task {
            await model.reloadSavedCards()
        }
    }
}

/// PROVISIONAL detail wrapper. Reuses the approved card object but does not
/// establish the final Saved detail screen hierarchy.
private struct SavedCardDetailView: View {
    @EnvironmentObject private var model: AppModel
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
                        Task { await model.removeSavedCard(id: card.id) }
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
