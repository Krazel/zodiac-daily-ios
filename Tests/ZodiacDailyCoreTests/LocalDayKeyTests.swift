import XCTest
@testable import ZodiacDailyCore

final class LocalDayKeyTests: XCTestCase {
    func testRoundTripsCanonicalValue() throws {
        let key = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        XCTAssertEqual(key.year, 2026)
        XCTAssertEqual(key.month, 8)
        XCTAssertEqual(key.day, 9)
        XCTAssertEqual(key.rawValue, "2026-08-09")

        let encoded = try JSONEncoder().encode(key)
        XCTAssertEqual(String(decoding: encoded, as: UTF8.self), "\"2026-08-09\"")
        XCTAssertEqual(try JSONDecoder().decode(LocalDayKey.self, from: encoded), key)
    }

    func testRejectsNonCanonicalAndImpossibleDates() {
        XCTAssertNil(LocalDayKey(rawValue: "2026-8-9"))
        XCTAssertNil(LocalDayKey(rawValue: "2026-02-29"))
        XCTAssertNotNil(LocalDayKey(rawValue: "2028-02-29"))
    }

    func testLocalDayChangesAtLocalMidnight() throws {
        let madrid = try XCTUnwrap(TimeZone(identifier: "Europe/Madrid"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = madrid

        let before = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026, month: 8, day: 9, hour: 23, minute: 59
        )))
        let after = try XCTUnwrap(calendar.date(byAdding: .minute, value: 2, to: before))

        XCTAssertEqual(LocalDayKey(date: before, timeZone: madrid).rawValue, "2026-08-09")
        XCTAssertEqual(LocalDayKey(date: after, timeZone: madrid).rawValue, "2026-08-10")
    }

    func testSameInstantUsesTheRequestedLocalTimeZone() throws {
        let instant = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-08-09T22:30:00Z"))
        let madrid = try XCTUnwrap(TimeZone(identifier: "Europe/Madrid"))
        let newYork = try XCTUnwrap(TimeZone(identifier: "America/New_York"))

        XCTAssertEqual(LocalDayKey(date: instant, timeZone: madrid).rawValue, "2026-08-10")
        XCTAssertEqual(LocalDayKey(date: instant, timeZone: newYork).rawValue, "2026-08-09")
    }

    func testSpringDSTTransitionKeepsTheGregorianDayStable() throws {
        let madrid = try XCTUnwrap(TimeZone(identifier: "Europe/Madrid"))
        let beforeJump = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-03-29T00:30:00Z"))
        let afterJump = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-03-29T01:30:00Z"))

        XCTAssertEqual(LocalDayKey(date: beforeJump, timeZone: madrid).rawValue, "2026-03-29")
        XCTAssertEqual(LocalDayKey(date: afterJump, timeZone: madrid).rawValue, "2026-03-29")
    }
}
