import XCTest
@testable import ZodiacDailyCore

final class FileBackedSavedCardStoreTests: XCTestCase {
    func testCardsSurviveStoreRecreation() async throws {
        let fileURL = temporaryArchiveURL()
        let card = try makeCard(sign: .pisces, day: "2026-08-09", savedAt: 100)

        let firstStore = FileBackedSavedCardStore(fileURL: fileURL)
        try await firstStore.save(card)

        let recreatedStore = FileBackedSavedCardStore(fileURL: fileURL)
        let recreatedCards = try await recreatedStore.allCards()
        XCTAssertEqual(recreatedCards, [card])
    }

    func testDuplicateSavePreservesOriginalSnapshotAcrossRelaunch() async throws {
        let fileURL = temporaryArchiveURL()
        let original = try makeCard(sign: .scorpio, day: "2026-08-09", savedAt: 100)
        let replacement = SavedCard(
            horoscope: DailyHoroscope(
                sign: .scorpio,
                day: original.horoscope.day,
                headline: "Replacement",
                reading: "This newer edition must not replace the snapshot.",
                contentVersion: 2
            ),
            savedAt: Date(timeIntervalSince1970: 200)
        )

        let store = FileBackedSavedCardStore(fileURL: fileURL)
        try await store.save(original)
        try await store.save(replacement)

        let recreatedStore = FileBackedSavedCardStore(fileURL: fileURL)
        let recreatedCard = try await recreatedStore.card(id: original.id)
        XCTAssertEqual(recreatedCard, original)
    }

    func testRemovalIsPersisted() async throws {
        let fileURL = temporaryArchiveURL()
        let card = try makeCard(sign: .aries, day: "2026-08-09", savedAt: 100)
        let store = FileBackedSavedCardStore(fileURL: fileURL)

        try await store.save(card)
        try await store.remove(id: card.id)

        let recreatedStore = FileBackedSavedCardStore(fileURL: fileURL)
        let recreatedCards = try await recreatedStore.allCards()
        XCTAssertTrue(recreatedCards.isEmpty)
    }

    func testLegacyArchiveWithoutDetailsRemainsReadable() async throws {
        let fileURL = temporaryArchiveURL()
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let legacyArchive = Data(
            """
            {
              "version": 1,
              "cards": [
                {
                  "horoscope": {
                    "sign": "pisces",
                    "day": "2026-08-09",
                    "headline": "Legacy headline",
                    "reading": "Legacy reading",
                    "contentVersion": 1
                  },
                  "savedAt": "1970-01-01T00:01:40Z"
                }
              ]
            }
            """.utf8
        )
        try legacyArchive.write(to: fileURL)

        let store = FileBackedSavedCardStore(fileURL: fileURL)
        let cards = try await store.allCards()
        let card = try XCTUnwrap(cards.first)
        XCTAssertEqual(card.horoscope.headline, "Legacy headline")
        XCTAssertEqual(
            card.horoscope.details,
            DailyCardDetails.offlineFallback(for: .pisces)
        )
    }

    func testCorruptArchiveReturnsAStableDomainError() async throws {
        let fileURL = temporaryArchiveURL()
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: fileURL)

        let store = FileBackedSavedCardStore(fileURL: fileURL)
        do {
            _ = try await store.allCards()
            XCTFail("Expected the corrupt archive to fail.")
        } catch {
            XCTAssertEqual(error as? FileBackedSavedCardStoreError, .invalidArchive)
        }
    }

    private func temporaryArchiveURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("ZodiacDailyTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("saved-cards.json")
    }

    private func makeCard(sign: ZodiacSign, day: String, savedAt: TimeInterval) throws -> SavedCard {
        let key = try XCTUnwrap(LocalDayKey(rawValue: day))
        return SavedCard(
            horoscope: DailyHoroscope(
                sign: sign,
                day: key,
                headline: "Test headline",
                reading: "Test reading",
                contentVersion: 1
            ),
            savedAt: Date(timeIntervalSince1970: savedAt)
        )
    }
}
