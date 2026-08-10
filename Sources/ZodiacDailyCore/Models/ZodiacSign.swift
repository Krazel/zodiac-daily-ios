import Foundation

/// The twelve western zodiac signs in calendar order.
public enum ZodiacSign: String, CaseIterable, Codable, Hashable, Sendable {
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces

    public var displayName: String {
        rawValue.prefix(1).uppercased() + String(rawValue.dropFirst())
    }

    public var symbol: String {
        switch self {
        case .aries: "\u{2648}\u{FE0E}"
        case .taurus: "\u{2649}\u{FE0E}"
        case .gemini: "\u{264A}\u{FE0E}"
        case .cancer: "\u{264B}\u{FE0E}"
        case .leo: "\u{264C}\u{FE0E}"
        case .virgo: "\u{264D}\u{FE0E}"
        case .libra: "\u{264E}\u{FE0E}"
        case .scorpio: "\u{264F}\u{FE0E}"
        case .sagittarius: "\u{2650}\u{FE0E}"
        case .capricorn: "\u{2651}\u{FE0E}"
        case .aquarius: "\u{2652}\u{FE0E}"
        case .pisces: "\u{2653}\u{FE0E}"
        }
    }
}
