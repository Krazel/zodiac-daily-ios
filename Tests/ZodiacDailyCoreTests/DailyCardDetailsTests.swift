import Foundation
import XCTest
@testable import ZodiacDailyCore

final class DailyCardDetailsTests: XCTestCase {
    func testDeterministicFallbackIsStableAndComplete() throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        for sign in ZodiacSign.allCases {
            let first = DailyCardDetails.deterministicFallback(for: sign, day: day)
            let repeated = DailyCardDetails.deterministicFallback(for: sign, day: day)

            XCTAssertEqual(first, repeated)
            XCTAssertFalse(first.love.isEmpty)
            XCTAssertFalse(first.work.isEmpty)
            XCTAssertFalse(first.wellBeing.isEmpty)
            XCTAssertFalse(first.luckyColor.isEmpty)
            XCTAssertTrue((1...99).contains(first.luckyNumber))
            XCTAssertFalse(first.signEssence.isEmpty)
        }
    }

    func testFallbackRespondsToSignAndDayWithoutPersonalData() throws {
        let firstDay = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let nextDay = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-10"))
        let pisces = DailyCardDetails.deterministicFallback(for: .pisces, day: firstDay)
        let nextPisces = DailyCardDetails.deterministicFallback(for: .pisces, day: nextDay)
        let scorpio = DailyCardDetails.deterministicFallback(for: .scorpio, day: firstDay)

        XCTAssertNotEqual(pisces, nextPisces)
        XCTAssertNotEqual(pisces.signEssence, scorpio.signEssence)
    }

    func testCodableRoundTripUsesStableSnakeCaseKeys() throws {
        let details = DailyCardDetails(
            love: "Love",
            work: "Work",
            wellBeing: "Well-being",
            luckyColor: "Amber",
            luckyNumber: 7,
            signEssence: "Essence"
        )

        let data = try JSONEncoder().encode(details)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        XCTAssertEqual(object["well_being"] as? String, "Well-being")
        XCTAssertEqual(object["lucky_color"] as? String, "Amber")
        XCTAssertEqual(object["lucky_number"] as? Int, 7)
        XCTAssertEqual(object["sign_essence"] as? String, "Essence")
        XCTAssertEqual(try JSONDecoder().decode(DailyCardDetails.self, from: data), details)
    }
}
