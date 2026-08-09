import Foundation

/// A Gregorian calendar day, independent from clock time.
///
/// Create it with the user's current time zone when deciding which daily
/// edition to show. Persisting the resulting `YYYY-MM-DD` value keeps that
/// edition stable if the device time zone later changes.
public struct LocalDayKey: RawRepresentable, Codable, Hashable, Comparable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    public var rawValue: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    public init?(rawValue: String) {
        let parts = rawValue.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3,
              parts[0].count == 4,
              parts[1].count == 2,
              parts[2].count == 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]),
              Self.isValid(year: year, month: month, day: day),
              String(format: "%04d-%02d-%02d", year, month, day) == rawValue
        else {
            return nil
        }

        self.year = year
        self.month = month
        self.day = day
    }

    public init?(year: Int, month: Int, day: Int) {
        guard Self.isValid(year: year, month: month, day: day) else {
            return nil
        }

        self.year = year
        self.month = month
        self.day = day
    }

    public init(date: Date, timeZone: TimeZone = .current) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        // Gregorian dates always provide these components.
        self.year = components.year!
        self.month = components.month!
        self.day = components.day!
    }

    public func startDate(in timeZone: TimeZone) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = timeZone
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    public static func < (lhs: LocalDayKey, rhs: LocalDayKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let key = Self(rawValue: value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected a valid Gregorian day in YYYY-MM-DD format."
            )
        }
        self = key
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    private static func isValid(year: Int, month: Int, day: Int) -> Bool {
        guard (1...9_999).contains(year) else { return false }

        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components) else { return false }
        let roundTrip = calendar.dateComponents([.year, .month, .day], from: date)
        return roundTrip.year == year && roundTrip.month == month && roundTrip.day == day
    }
}
