import XCTest
@testable import ZodiacDailyCore

final class SavedCardStoreTests: XCTestCase {
    func testSavingTheSameSignAndDayTwiceDoesNotCreateADuplicate() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let horoscope = DailyHoroscope(
            sign: .scorpio,
            day: day,
            headline: "Trust what the surface cannot explain",
            reading: "A stable test reading.",
            contentVersion: 1
        )
        let firstSavedAt = Date(timeIntervalSince1970: 100)
        let store = InMemorySavedCardStore()

        try await store.save(SavedCard(horoscope: horoscope, savedAt: firstSavedAt))
        try await store.save(SavedCard(horoscope: horoscope, savedAt: Date(timeIntervalSince1970: 200)))

        let cards = try await store.allCards()
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.savedAt, firstSavedAt)
    }

    func testLookupAndRemovalUseStableCardIdentity() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let horoscope = DailyHoroscope(
            sign: .aries,
            day: day,
            headline: "Choose the first brave step",
            reading: "A stable test reading.",
            contentVersion: 1
        )
        let card = SavedCard(horoscope: horoscope, savedAt: Date(timeIntervalSince1970: 100))
        let store = InMemorySavedCardStore()

        try await store.save(card)
        let found = try await store.card(id: card.id)
        XCTAssertEqual(found, card)

        try await store.remove(id: card.id)
        let removed = try await store.card(id: card.id)
        XCTAssertNil(removed)
    }

    func testContentUpdateDoesNotReplaceAnExistingSavedSnapshot() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let original = DailyHoroscope(
            sign: .pisces,
            day: day,
            headline: "Original headline",
            reading: "Original reading",
            contentVersion: 1
        )
        let updated = DailyHoroscope(
            sign: .pisces,
            day: day,
            headline: "Updated headline",
            reading: "Updated reading",
            contentVersion: 2
        )
        let store = InMemorySavedCardStore()

        XCTAssertNotEqual(original.id, updated.id)
        XCTAssertEqual(original.archiveKey, updated.archiveKey)

        try await store.save(SavedCard(horoscope: original, savedAt: Date(timeIntervalSince1970: 100)))
        try await store.save(SavedCard(horoscope: updated, savedAt: Date(timeIntervalSince1970: 200)))

        let cards = try await store.allCards()
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.horoscope, original)
    }

    func testCardsAreReturnedNewestDayFirst() async throws {
        let oldDay = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-08"))
        let newDay = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let store = InMemorySavedCardStore()

        try await store.save(SavedCard(horoscope: makeHoroscope(sign: .pisces, day: oldDay)))
        try await store.save(SavedCard(horoscope: makeHoroscope(sign: .aries, day: newDay)))

        let cards = try await store.allCards()
        XCTAssertEqual(cards.map(\.horoscope.day), [newDay, oldDay])
    }

    func testEnglishAndSpanishSnapshotsForSameSignAndDayCoexist() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let store = InMemorySavedCardStore()
        let english = DailyHoroscope(
            sign: .pisces,
            day: day,
            language: .english,
            headline: "English",
            reading: "English reading",
            contentVersion: 1
        )
        let spanish = DailyHoroscope(
            sign: .pisces,
            day: day,
            language: .spanish,
            headline: "Español",
            reading: "Lectura en español",
            contentVersion: 1
        )

        try await store.save(SavedCard(horoscope: english))
        try await store.save(SavedCard(horoscope: spanish))

        let cards = try await store.allCards()
        XCTAssertEqual(cards.count, 2)
        XCTAssertEqual(cards.map(\.horoscope.language), [.english, .spanish])
    }

    private func makeHoroscope(sign: ZodiacSign, day: LocalDayKey) -> DailyHoroscope {
        DailyHoroscope(
            sign: sign,
            day: day,
            headline: "Test headline",
            reading: "Test reading",
            contentVersion: 1
        )
    }
}
