import Foundation

public protocol HoroscopeRepository: Sendable {
    func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope
}

public extension HoroscopeRepository {
    /// Backwards-compatible convenience for callers that only need the
    /// original English edition.
    func horoscope(for sign: ZodiacSign, day: LocalDayKey) async throws -> DailyHoroscope {
        try await horoscope(for: sign, day: day, language: .english)
    }
}

public enum HoroscopeRepositoryError: Error, Equatable, Sendable {
    case resourceMissing(String)
    case invalidResource
    case missingContent(ZodiacSign)
}

extension HoroscopeRepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .resourceMissing(let name):
            "The bundled horoscope resource '\(name)' could not be found."
        case .invalidResource:
            "The bundled horoscope content is invalid."
        case .missingContent(let sign):
            "No bundled horoscope content exists for \(sign.displayName)."
        }
    }
}
