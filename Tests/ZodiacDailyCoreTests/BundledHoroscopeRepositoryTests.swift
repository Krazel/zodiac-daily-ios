import XCTest
@testable import ZodiacDailyCore

final class BundledHoroscopeRepositoryTests: XCTestCase {
    func testBundledCatalogProvidesEnglishContentForAllTwelveSigns() async throws {
        let repository = try BundledHoroscopeRepository()
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        var returnedSigns = Set<ZodiacSign>()
        for sign in ZodiacSign.allCases {
            let horoscope = try await repository.horoscope(for: sign, day: day)
            returnedSigns.insert(horoscope.sign)
            XCTAssertEqual(horoscope.day, day)
            XCTAssertFalse(horoscope.headline.isEmpty)
            XCTAssertFalse(horoscope.reading.isEmpty)
            XCTAssertEqual(horoscope.contentVersion, 1)
        }

        XCTAssertEqual(returnedSigns, Set(ZodiacSign.allCases))
    }

    func testSameSignAndDayIsStableAcrossRepositoryInstances() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let firstRepository = try BundledHoroscopeRepository()
        let secondRepository = try BundledHoroscopeRepository()

        let first = try await firstRepository.horoscope(for: .scorpio, day: day)
        let repeated = try await firstRepository.horoscope(for: .scorpio, day: day)
        let recreated = try await secondRepository.horoscope(for: .scorpio, day: day)

        XCTAssertEqual(first, repeated)
        XCTAssertEqual(first, recreated)
    }

    func testKnownEditionIsPinnedAcrossProcesses() async throws {
        let repository = try BundledHoroscopeRepository()
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let horoscope = try await repository.horoscope(for: .scorpio, day: day)

        XCTAssertEqual(horoscope.headline, "Trust what the surface cannot explain")
        XCTAssertEqual(
            horoscope.reading,
            "Your instincts are precise today, especially around what remains unsaid. Use that knowledge to ask a clear question rather than drawing a final conclusion alone."
        )
    }

    func testNextLocalDayProducesANewDailyCardIdentity() async throws {
        let repository = try BundledHoroscopeRepository()
        let firstDay = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let nextDay = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-10"))

        let first = try await repository.horoscope(for: .sagittarius, day: firstDay)
        let next = try await repository.horoscope(for: .sagittarius, day: nextDay)

        XCTAssertNotEqual(first.id, next.id)
        XCTAssertNotEqual(first, next)
        XCTAssertEqual(next.day, nextDay)
    }

    func testInvalidCatalogIsRejected() {
        XCTAssertThrowsError(try BundledHoroscopeRepository(data: Data("{}".utf8))) { error in
            XCTAssertEqual(error as? HoroscopeRepositoryError, .invalidResource)
        }
    }

    func testCatalogWithBlankAuthoredContentIsRejected() throws {
        let signs = Dictionary(uniqueKeysWithValues: ZodiacSign.allCases.map {
            ($0.rawValue, ["headlines": [" "], "readings": ["Valid reading"]])
        })
        let data = try JSONSerialization.data(withJSONObject: ["version": 1, "signs": signs])

        XCTAssertThrowsError(try BundledHoroscopeRepository(data: data)) { error in
            XCTAssertEqual(error as? HoroscopeRepositoryError, .invalidResource)
        }
    }
}
