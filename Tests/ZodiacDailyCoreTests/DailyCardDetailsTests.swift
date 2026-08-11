import Foundation
import XCTest
@testable import ZodiacDailyCore

final class DailyCardDetailsTests: XCTestCase {
    func testProviderDetailsAreCompleteAndUseStableSnakeCaseKeys() throws {
        let details = makeProviderDetails()

        XCTAssertTrue(details.hasProviderData)
        XCTAssertEqual(details.source, .freeAstroAPIV2)
        XCTAssertEqual(details.loveScore, 83)
        XCTAssertEqual(details.luckyNumber, 61)

        let data = try JSONEncoder().encode(details)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["source"] as? String, "freeastroapi-v2")
        XCTAssertEqual(object["love_score"] as? Int, 83)
        XCTAssertEqual(object["lucky_color"] as? String, "Silver")
        XCTAssertEqual(object["moon_phase"] as? String, "Last Quarter")
        XCTAssertEqual(try JSONDecoder().decode(DailyCardDetails.self, from: data), details)
    }

    func testOfflineFallbackNeverInventsDailyValues() {
        for sign in ZodiacSign.allCases {
            let details = DailyCardDetails.offlineFallback(for: sign)

            XCTAssertEqual(details.source, .offline)
            XCTAssertEqual(details.focus, "Offline Edition")
            XCTAssertTrue(details.keywords.isEmpty)
            XCTAssertNil(details.loveScore)
            XCTAssertNil(details.careerScore)
            XCTAssertNil(details.moneyScore)
            XCTAssertNil(details.healthScore)
            XCTAssertNil(details.luckyColor)
            XCTAssertNil(details.luckyNumber)
            XCTAssertNil(details.moonSign)
            XCTAssertNil(details.moonPhase)
            XCTAssertFalse(details.signEssence.isEmpty)
            XCTAssertFalse(details.hasProviderData)
        }
    }

    func testLegacyGeneratedDetailsDecodeAsHonestOfflineEdition() throws {
        let data = Data(
            """
            {
              "love": "Invented legacy love text.",
              "work": "Invented legacy work text.",
              "well_being": "Invented legacy well-being text.",
              "lucky_color": "Amber",
              "lucky_number": 7,
              "sign_essence": "Preserved essence."
            }
            """.utf8
        )

        let decoded = try JSONDecoder().decode(DailyCardDetails.self, from: data)

        XCTAssertEqual(decoded.source, .offline)
        XCTAssertEqual(decoded.focus, "Offline Edition")
        XCTAssertTrue(decoded.keywords.isEmpty)
        XCTAssertNil(decoded.luckyColor)
        XCTAssertNil(decoded.luckyNumber)
        XCTAssertEqual(decoded.signEssence, "Preserved essence.")
    }

    func testSpanishDetailsUseSpanishEssenceAndOfflineLabel() {
        let details = DailyCardDetails.offlineFallback(
            for: .pisces,
            language: .spanish
        )

        XCTAssertEqual(details.focus, "Edición sin conexión")
        XCTAssertEqual(details.signEssence, "Intuitivo · Compasivo · Imaginativo")
    }

    private func makeProviderDetails() -> DailyCardDetails {
        .provider(
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
    }
}
