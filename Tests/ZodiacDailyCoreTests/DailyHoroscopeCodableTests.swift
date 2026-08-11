import Foundation
import XCTest
@testable import ZodiacDailyCore

final class DailyHoroscopeCodableTests: XCTestCase {
    func testLegacyEditionWithoutDetailsDecodesOfflineFallback() throws {
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
        XCTAssertEqual(decoded.language, .english)
        XCTAssertEqual(
            decoded.details,
            DailyCardDetails.offlineFallback(for: .pisces)
        )
    }

    func testEnglishAndSpanishEditionsHaveIndependentArchiveIdentity() throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
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

        XCTAssertEqual(english.archiveKey, "en:pisces:2026-08-09")
        XCTAssertEqual(spanish.archiveKey, "es:pisces:2026-08-09")
        XCTAssertNotEqual(english.archiveKey, spanish.archiveKey)
    }

    func testCurrentEditionRoundTripPreservesExactDetailsSnapshot() throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let details = DailyCardDetails.provider(
            focus: "Intuition",
            keywords: ["Empathy", "Flow", "Imagination"],
            loveScore: 83,
            careerScore: 89,
            moneyScore: 85,
            healthScore: 78,
            luckyColor: "Silver",
            luckyNumber: 61,
            moonSign: "Capricorn",
            moonPhase: "Last Quarter",
            sign: .pisces
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

    func testExistingInitializerAutomaticallyAddsOfflineDetails() throws {
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
            DailyCardDetails.offlineFallback(for: .scorpio)
        )
    }
}
