import Foundation

/// Persistence boundary for saved cards. A SwiftData implementation can adopt
/// this later without changing feature logic.
public protocol SavedCardStore: Sendable {
    func save(_ card: SavedCard) async throws
    func remove(id: SavedCard.ID) async throws
    func card(id: SavedCard.ID) async throws -> SavedCard?
    func allCards() async throws -> [SavedCard]
}

public enum FileBackedSavedCardStoreError: Error, Equatable, Sendable {
    case unsupportedVersion(Int)
    case invalidArchive
}

public enum FileBackedSavedCardStoreRecoveryPolicy: Sendable {
    /// Preserve the archive and surface the error. This is the safe default
    /// for user-owned saved cards.
    case fail

    /// Treat an unreadable archive as a disposable cache. The next successful
    /// save atomically replaces it with a valid archive.
    case replaceCorruptArchive
}

extension FileBackedSavedCardStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupportedVersion(let version):
            "The saved-card archive uses unsupported version \(version)."
        case .invalidArchive:
            "The saved-card archive could not be read."
        }
    }
}

/// A durable, actor-isolated JSON archive for the app's saved-card snapshots.
///
/// The store loads lazily so constructing app dependencies never performs disk
/// I/O on the main actor. Writes use Foundation's atomic replacement option,
/// and an existing snapshot is never overwritten by a later content edition.
public actor FileBackedSavedCardStore: SavedCardStore {
    private struct Archive: Codable, Sendable {
        let version: Int
        let cards: [SavedCard]
    }

    private let fileURL: URL
    private let recoveryPolicy: FileBackedSavedCardStoreRecoveryPolicy
    private var cardsByID: [SavedCard.ID: SavedCard] = [:]
    private var hasLoaded = false

    public init(
        fileURL: URL,
        recoveryPolicy: FileBackedSavedCardStoreRecoveryPolicy = .fail
    ) {
        self.fileURL = fileURL
        self.recoveryPolicy = recoveryPolicy
    }

    public func save(_ card: SavedCard) async throws {
        try loadIfNeeded()
        guard cardsByID[card.id] == nil else { return }

        var updated = cardsByID
        updated[card.id] = card
        try persist(updated)
        cardsByID = updated
    }

    public func remove(id: SavedCard.ID) async throws {
        try loadIfNeeded()
        guard cardsByID[id] != nil else { return }

        var updated = cardsByID
        updated.removeValue(forKey: id)
        try persist(updated)
        cardsByID = updated
    }

    public func card(id: SavedCard.ID) async throws -> SavedCard? {
        try loadIfNeeded()
        return cardsByID[id]
    }

    public func allCards() async throws -> [SavedCard] {
        try loadIfNeeded()
        return sortedCards(in: cardsByID)
    }

    private func loadIfNeeded() throws {
        guard !hasLoaded else { return }
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            hasLoaded = true
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let archive = try decoder.decode(Archive.self, from: data)
            guard archive.version == 1 else {
                throw FileBackedSavedCardStoreError.unsupportedVersion(archive.version)
            }
            cardsByID = Dictionary(
                archive.cards.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
            hasLoaded = true
        } catch let error as FileBackedSavedCardStoreError {
            try recoverOrThrow(error)
        } catch {
            try recoverOrThrow(FileBackedSavedCardStoreError.invalidArchive)
        }
    }

    private func recoverOrThrow(_ error: FileBackedSavedCardStoreError) throws {
        switch recoveryPolicy {
        case .fail:
            throw error
        case .replaceCorruptArchive:
            cardsByID = [:]
            hasLoaded = true
        }
    }

    private func persist(_ cards: [SavedCard.ID: SavedCard]) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let archive = Archive(version: 1, cards: sortedCards(in: cards))
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(archive).write(to: fileURL, options: .atomic)
    }

    private func sortedCards(in cards: [SavedCard.ID: SavedCard]) -> [SavedCard] {
        cards.values.sorted {
            if $0.horoscope.day != $1.horoscope.day {
                return $0.horoscope.day > $1.horoscope.day
            }
            return $0.horoscope.sign.rawValue < $1.horoscope.sign.rawValue
        }
    }
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
