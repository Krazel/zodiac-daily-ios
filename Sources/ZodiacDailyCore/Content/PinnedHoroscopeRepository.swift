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

/// Pins the first successfully resolved edition for each sign and local day.
///
/// Remote availability can change during a day. Persisting the first result
/// before returning it keeps the collectible card stable across refreshes and
/// app relaunches, regardless of whether that first result was remote or the
/// bundled fallback.
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
            return pinned.horoscope
        }

        let resolved = try await upstream.horoscope(
            for: sign,
            day: day,
            language: language
        )
        let isPermittedEnglishFallback = language == .spanish && resolved.language == .english
        guard resolved.sign == sign,
              resolved.day == day,
              resolved.language == language || isPermittedEnglishFallback else {
            throw PinnedHoroscopeRepositoryError.mismatchedEdition
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
