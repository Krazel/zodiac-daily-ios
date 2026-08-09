import Foundation

/// A local snapshot of a daily card at the moment the user saves it.
public struct SavedCard: Codable, Hashable, Identifiable, Sendable {
    public let horoscope: DailyHoroscope
    public let savedAt: Date

    public var id: String { horoscope.archiveKey }

    public init(horoscope: DailyHoroscope, savedAt: Date = Date()) {
        self.horoscope = horoscope
        self.savedAt = savedAt
    }
}
