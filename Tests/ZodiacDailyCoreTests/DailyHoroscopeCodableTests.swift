import Foundation
import XCTest
@testable import ZodiacDailyCore

final class DailyHoroscopeCodableTests: XCTestCase {
    func testLegacyEditionWithoutDetailsDecodesDeterministicFallback() throws {
        let data = Data(
            """
            {
              "sign": "pisces",
              "day": "2026-08-09",
              "headline": "Let the Tide Turn",
              "reading": "A complete legacy reading.",
              "contentVersion": 1
            }
            """.utf8
        )
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let decoded = try JSONDecoder().decode(DailyHoroscope.self, from: data)

        XCTAssertEqual(decoded.sign, .pisces)
        XCTAssertEqual(decoded.day, day)
        XCTAssertEqual(
            decoded.details,
            DailyCardDetails.deterministicFallback(for: .pisces, day: day)
        )
    }

    func testCurrentEditionRoundTripPreservesExactDetailsSnapshot() throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let details = DailyCardDetails(
            love: "Keep this exact love snapshot.",
            work: "Keep this exact work snapshot.",
            wellBeing: "Keep this exact well-being snapshot.",
            luckyColor: "Ocean Teal",
            luckyNumber: 27,
            signEssence: "Keep this exact essence."
        )
        let edition = DailyHoroscope(
            sign: .pisces,
            day: day,
            headline: "Let the Tide Turn",
            reading: "A complete current reading.",
            details: details,
            contentVersion: 2
        )

        let data = try JSONEncoder().encode(edition)
        let decoded = try JSONDecoder().decode(DailyHoroscope.self, from: data)

        XCTAssertEqual(decoded, edition)
        XCTAssertEqual(decoded.details, details)
    }

    func testExistingInitializerAutomaticallyAddsFallbackDetails() throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let edition = DailyHoroscope(
            sign: .scorpio,
            day: day,
            headline: "Headline",
            reading: "Reading",
            contentVersion: 1
        )

        XCTAssertEqual(
            edition.details,
            DailyCardDetails.deterministicFallback(for: .scorpio, day: day)
        )
    }
}
