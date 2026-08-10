import Foundation

/// An immutable daily edition resolved from remote or bundled English content.
public struct DailyHoroscope: Codable, Hashable, Identifiable, Sendable {
    public let sign: ZodiacSign
    public let day: LocalDayKey
    public let headline: String
    public let reading: String
    public let details: DailyCardDetails
    public let contentVersion: Int

    /// Identifies the generated edition. A content update creates a new
    /// edition without changing the archive slot for that sign and day.
    public var id: String { "\(archiveKey):v\(contentVersion)" }

    /// A sign/day can appear only once in the saved archive. The first saved
    /// snapshot remains intact even if bundled content changes later.
    public var archiveKey: String { "\(sign.rawValue):\(day.rawValue)" }

    public init(
        sign: ZodiacSign,
        day: LocalDayKey,
        headline: String,
        reading: String,
        details: DailyCardDetails? = nil,
        contentVersion: Int
    ) {
        self.sign = sign
        self.day = day
        self.headline = headline
        self.reading = reading
        self.details = details ?? .deterministicFallback(for: sign, day: day)
        self.contentVersion = contentVersion
    }

    private enum CodingKeys: String, CodingKey {
        case sign
        case day
        case headline
        case reading
        case details
        case contentVersion
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sign = try container.decode(ZodiacSign.self, forKey: .sign)
        let day = try container.decode(LocalDayKey.self, forKey: .day)

        self.sign = sign
        self.day = day
        headline = try container.decode(String.self, forKey: .headline)
        reading = try container.decode(String.self, forKey: .reading)
        details = try container.decodeIfPresent(DailyCardDetails.self, forKey: .details)
            ?? .deterministicFallback(for: sign, day: day)
        contentVersion = try container.decode(Int.self, forKey: .contentVersion)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sign, forKey: .sign)
        try container.encode(day, forKey: .day)
        try container.encode(headline, forKey: .headline)
        try container.encode(reading, forKey: .reading)
        try container.encode(details, forKey: .details)
        try container.encode(contentVersion, forKey: .contentVersion)
    }
}
