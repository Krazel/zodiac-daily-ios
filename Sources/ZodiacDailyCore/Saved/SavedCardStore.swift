import Foundation

/// Persistence boundary for saved cards. A SwiftData implementation can adopt
/// this later without changing feature logic.
public protocol SavedCardStore: Sendable {
    func save(_ card: SavedCard) async throws
    func remove(id: SavedCard.ID) async throws
    func card(id: SavedCard.ID) async throws -> SavedCard?
    func allCards() async throws -> [SavedCard]
}

/// Thread-safe, deterministic storage intended for tests and previews only.
public actor InMemorySavedCardStore: SavedCardStore {
    private var cardsByID: [SavedCard.ID: SavedCard]

    public init(cards: [SavedCard] = []) {
        self.cardsByID = Dictionary(cards.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    public func save(_ card: SavedCard) async throws {
        // Saving an already-saved daily card is idempotent and preserves its
        // original saved timestamp.
        if cardsByID[card.id] == nil {
            cardsByID[card.id] = card
        }
    }

    public func remove(id: SavedCard.ID) async throws {
        cardsByID.removeValue(forKey: id)
    }

    public func card(id: SavedCard.ID) async throws -> SavedCard? {
        cardsByID[id]
    }

    public func allCards() async throws -> [SavedCard] {
        cardsByID.values.sorted {
            if $0.horoscope.day != $1.horoscope.day {
                return $0.horoscope.day > $1.horoscope.day
            }
            return $0.horoscope.sign.rawValue < $1.horoscope.sign.rawValue
        }
    }
}
