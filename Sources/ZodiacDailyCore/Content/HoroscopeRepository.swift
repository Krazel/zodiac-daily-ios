import Foundation

public protocol HoroscopeRepository: Sendable {
    func horoscope(for sign: ZodiacSign, day: LocalDayKey) async throws -> DailyHoroscope
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
