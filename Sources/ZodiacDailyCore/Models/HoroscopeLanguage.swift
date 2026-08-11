import Foundation

/// Language of the editorial horoscope content itself.
///
/// This is deliberately separate from the interface locale: a Spanish UI may
/// temporarily display the bundled English fallback while the translated
/// daily edition is unavailable.
public enum HoroscopeLanguage: String, Codable, CaseIterable, Hashable, Sendable {
    case english = "en"
    case spanish = "es"
}
