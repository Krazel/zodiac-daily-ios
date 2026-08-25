import Foundation
import XCTest
@testable import ZodiacDailyCore

final class PinnedHoroscopeRepositoryTests: XCTestCase {
    func testFirstResolvedEditionRemainsStableWhenUpstreamChanges() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let first = makeHoroscope(day: day, headline: "First", version: 1)
        let second = makeHoroscope(day: day, headline: "Second", version: 2)
        let upstream = MutableHoroscopeRepository(first)
        let repository = PinnedHoroscopeRepository(
            upstream: upstream,
            store: InMemorySavedCardStore(),
            now: { Date(timeIntervalSince1970: 100) }
        )

        let initial = try await repository.horoscope(for: .scorpio, day: day)
        await upstream.set(second)
        let refreshed = try await repository.horoscope(for: .scorpio, day: day)
        let callCount = await upstream.callCount

        XCTAssertEqual(initial, first)
        XCTAssertEqual(refreshed, first)
        XCTAssertEqual(callCount, 1)
    }

    func testPinnedEditionSurvivesRepositoryRelaunch() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let first = makeHoroscope(day: day, headline: "First", version: 1)
        let replacement = makeHoroscope(day: day, headline: "Replacement", version: 2)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directory.appendingPathComponent("daily-editions.json")
        defer { try? FileManager.default.removeItem(at: directory) }

        let firstRepository = PinnedHoroscopeRepository(
            upstream: MutableHoroscopeRepository(first),
            store: FileBackedSavedCardStore(fileURL: fileURL)
        )
        _ = try await firstRepository.horoscope(for: .scorpio, day: day)

        let replacementUpstream = MutableHoroscopeRepository(replacement)
        let relaunchedRepository = PinnedHoroscopeRepository(
            upstream: replacementUpstream,
            store: FileBackedSavedCardStore(fileURL: fileURL)
        )
        let relaunched = try await relaunchedRepository.horoscope(for: .scorpio, day: day)
        let replacementCallCount = await replacementUpstream.callCount

        XCTAssertEqual(relaunched, first)
        XCTAssertEqual(replacementCallCount, 0)
    }

    func testConcurrentCallersConvergeOnOneStoredSnapshot() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let first = makeHoroscope(day: day, headline: "First", version: 1)
        let second = makeHoroscope(day: day, headline: "Second", version: 2)
        let repository = PinnedHoroscopeRepository(
            upstream: RotatingHoroscopeRepository([first, second]),
            store: InMemorySavedCardStore()
        )

        async let left = repository.horoscope(for: .scorpio, day: day)
        async let right = repository.horoscope(for: .scorpio, day: day)
        let (leftResult, rightResult) = try await (left, right)

        XCTAssertEqual(leftResult, rightResult)
    }

    func testCorruptDerivedCacheIsRebuiltFromUpstream() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let expected = makeHoroscope(day: day, headline: "Recovered", version: 3)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directory.appendingPathComponent("daily-editions.json")
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: fileURL)
        defer { try? FileManager.default.removeItem(at: directory) }

        let repository = PinnedHoroscopeRepository(
            upstream: MutableHoroscopeRepository(expected),
            store: FileBackedSavedCardStore(
                fileURL: fileURL,
                recoveryPolicy: .replaceCorruptArchive
            )
        )

        let recovered = try await repository.horoscope(for: .scorpio, day: day)
        let recreatedStore = FileBackedSavedCardStore(fileURL: fileURL)
        let persisted = try await recreatedStore.card(id: expected.archiveKey)

        XCTAssertEqual(recovered, expected)
        XCTAssertEqual(persisted?.horoscope, expected)
    }

    func testValidResolvedCardIsReturnedWhenDerivedCacheCannotWrite() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let expected = makeHoroscope(day: day, headline: "Available", version: 4)
        let repository = PinnedHoroscopeRepository(
            upstream: MutableHoroscopeRepository(expected),
            store: WriteFailingSavedCardStore()
        )

        let result = try await repository.horoscope(for: .scorpio, day: day)

        XCTAssertEqual(result, expected)
    }

    func testPinnedEditionsAreIndependentByLanguage() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let english = makeHoroscope(day: day, headline: "English", version: 1)
        let spanish = DailyHoroscope(
            sign: .scorpio,
            day: day,
            language: .spanish,
            headline: "Español",
            reading: "Una lectura diaria completa y estable para las pruebas.",
            contentVersion: 1
        )
        let upstream = LanguageHoroscopeRepository(english: english, spanish: spanish)
        let repository = PinnedHoroscopeRepository(
            upstream: upstream,
            store: InMemorySavedCardStore()
        )

        let resolvedEnglish = try await repository.horoscope(
            for: .scorpio,
            day: day,
            language: .english
        )
        let resolvedSpanish = try await repository.horoscope(
            for: .scorpio,
            day: day,
            language: .spanish
        )

        XCTAssertEqual(resolvedEnglish, english)
        XCTAssertEqual(resolvedSpanish, spanish)
        XCTAssertNotEqual(resolvedEnglish.archiveKey, resolvedSpanish.archiveKey)
    }

    func testSpanishRequestRejectsEnglishEdition() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let english = makeHoroscope(day: day, headline: "English only", version: 1)
        let repository = PinnedHoroscopeRepository(
            upstream: MutableHoroscopeRepository(english),
            store: InMemorySavedCardStore()
        )

        do {
            _ = try await repository.horoscope(
                for: .scorpio,
                day: day,
                language: .spanish
            )
            XCTFail("Expected a mismatched-language error")
        } catch {
            XCTAssertEqual(
                error as? PinnedHoroscopeRepositoryError,
                .mismatchedEdition
            )
        }
    }

    func testLegacyIncompletePinIsReplacedByCompleteProviderEdition() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directory.appendingPathComponent("daily-editions.json")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try Data(
            """
            {
              "version": 1,
              "cards": [{
                "horoscope": {
                  "sign": "scorpio",
                  "day": "2026-08-09",
                  "headline": "Legacy pinned",
                  "reading": "A complete legacy pinned reading for migration.",
                  "contentVersion": 1
                },
                "savedAt": "1970-01-01T00:01:40Z"
              }]
            }
            """.utf8
        ).write(to: fileURL)
        let complete = makeHoroscope(day: day, headline: "Complete provider edition", version: 2)
        let upstream = MutableHoroscopeRepository(complete)
        let repository = PinnedHoroscopeRepository(
            upstream: upstream,
            store: FileBackedSavedCardStore(fileURL: fileURL)
        )

        let resolved = try await repository.horoscope(
            for: .scorpio,
            day: day,
            language: .english
        )

        XCTAssertEqual(resolved, complete)
        XCTAssertEqual(resolved.archiveKey, "en:scorpio:2026-08-09")
        let upstreamCallCount = await upstream.callCount
        XCTAssertEqual(upstreamCallCount, 1)
    }

    private func makeHoroscope(
        day: LocalDayKey,
        headline: String,
        version: Int
    ) -> DailyHoroscope {
        DailyHoroscope(
            sign: .scorpio,
            day: day,
            headline: headline,
            reading: "A complete and stable daily reading for repository tests.",
            details: .provider(
                focus: headline,
                keywords: ["Clarity", "Focus"],
                loveScore: 81,
                careerScore: 84,
                moneyScore: 76,
                healthScore: 79,
                luckyColor: "Indigo",
                luckyNumber: 8,
                moonSign: "Capricorn",
                moonPhase: "Waxing Moon",
                sign: .scorpio
            ),
            contentVersion: version
        )
    }
}

private actor MutableHoroscopeRepository: HoroscopeRepository {
    private var horoscope: DailyHoroscope
    private(set) var callCount = 0

    init(_ horoscope: DailyHoroscope) {
        self.horoscope = horoscope
    }

    func set(_ horoscope: DailyHoroscope) {
        self.horoscope = horoscope
    }

    func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope {
        callCount += 1
        return horoscope
    }
}

private actor RotatingHoroscopeRepository: HoroscopeRepository {
    private var values: [DailyHoroscope]

    init(_ values: [DailyHoroscope]) {
        self.values = values
    }

    func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope {
        guard !values.isEmpty else {
            throw PinnedHoroscopeRepositoryError.mismatchedEdition
        }
        return values.removeFirst()
    }
}

private actor LanguageHoroscopeRepository: HoroscopeRepository {
    let english: DailyHoroscope
    let spanish: DailyHoroscope

    init(english: DailyHoroscope, spanish: DailyHoroscope) {
        self.english = english
        self.spanish = spanish
    }

    func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope {
        language == .spanish ? spanish : english
    }
}

private enum WriteFailure: Error {
    case unavailable
}

private actor WriteFailingSavedCardStore: SavedCardStore {
    func save(_ card: SavedCard) async throws {
        throw WriteFailure.unavailable
    }

    func remove(id: SavedCard.ID) async throws {}

    func card(id: SavedCard.ID) async throws -> SavedCard? {
        nil
    }

    func allCards() async throws -> [SavedCard] {
        []
    }
}
