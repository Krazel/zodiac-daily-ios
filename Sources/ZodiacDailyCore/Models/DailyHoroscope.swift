import Foundation

/// An immutable daily edition generated from bundled English content.
public struct DailyHoroscope: Codable, Hashable, Identifiable, Sendable {
    public let sign: ZodiacSign
    public let day: LocalDayKey
    public let headline: String
    public let reading: String
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
        contentVersion: Int
    ) {
        self.sign = sign
        self.day = day
        self.headline = headline
        self.reading = reading
        self.contentVersion = contentVersion
    }
}
