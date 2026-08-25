import Foundation

public enum PinnedHoroscopeRepositoryError: Error, Equatable, Sendable {
    case mismatchedEdition
}

extension PinnedHoroscopeRepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .mismatchedEdition:
            "The daily edition did not match the requested sign and date."
        }
    }
}

/// Pins the first complete provider edition for each sign and local day.
///
/// Remote availability can change during a day. Persisting the first complete
/// result keeps the collectible card stable across refreshes and relaunches.
/// Bundled emergency editions remain temporary so a later online refresh can
/// replace them with the provider's complete scores and lucky details.
public actor PinnedHoroscopeRepository: HoroscopeRepository {
    private let upstream: any HoroscopeRepository
    private let store: any SavedCardStore
    private let now: @Sendable () -> Date

    public init(
        upstream: any HoroscopeRepository,
        store: any SavedCardStore,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.upstream = upstream
        self.store = store
        self.now = now
    }

    public func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope {
        let archiveKey = "\(language.rawValue):\(sign.rawValue):\(day.rawValue)"
        if let pinned = try await store.card(id: archiveKey) {
            if pinned.horoscope.details.hasProviderData {
                return pinned.horoscope
            }

            // Older builds pinned the bundled emergency edition for the whole
            // day. That made provider scores and lucky details remain missing
            // even after connectivity returned. This cache is derived data,
            // unlike Saved, so discard only the incomplete pin and retry the
            // live edition. User-saved snapshots remain untouched.
            try? await store.remove(id: archiveKey)
        }

        let resolved = try await upstream.horoscope(
            for: sign,
            day: day,
            language: language
        )
        guard resolved.sign == sign,
              resolved.day == day,
              resolved.language == language else {
            throw PinnedHoroscopeRepositoryError.mismatchedEdition
        }

        guard resolved.details.hasProviderData else {
            return resolved
        }

        do {
            try await store.save(SavedCard(horoscope: resolved, savedAt: now()))

            // Concurrent callers may both resolve upstream content. The store
            // is first-write-wins, so rereading makes every caller converge on
            // the same immutable edition.
            return try await store.card(id: resolved.archiveKey)?.horoscope ?? resolved
        } catch {
            // A derived cache must never hide an otherwise valid daily card
            // merely because local storage is temporarily unavailable.
            return resolved
        }
    }
}
