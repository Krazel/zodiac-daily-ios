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
        case .aries: "♈"
        case .taurus: "♉"
        case .gemini: "♊"
        case .cancer: "♋"
        case .leo: "♌"
        case .virgo: "♍"
        case .libra: "♎"
        case .scorpio: "♏"
        case .sagittarius: "♐"
        case .capricorn: "♑"
        case .aquarius: "♒"
        case .pisces: "♓"
        }
    }
}
