import XCTest
@testable import ZodiacDailyCore

final class ZodiacSignTests: XCTestCase {
    func testContainsExactlyTheTwelveSignsInCalendarOrder() {
        XCTAssertEqual(
            ZodiacSign.allCases.map(\.rawValue),
            [
                "aries", "taurus", "gemini", "cancer", "leo", "virgo",
                "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"
            ]
        )
        XCTAssertEqual(Set(ZodiacSign.allCases.map(\.symbol)).count, 12)
    }

    func testEnglishDisplayNamesAreAvailableForEverySign() {
        for sign in ZodiacSign.allCases {
            XCTAssertFalse(sign.displayName.isEmpty)
            XCTAssertTrue(sign.displayName.first?.isUppercase == true)
        }
    }
}
