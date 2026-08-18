import Foundation

/// Prefers fresh remote content. The bundled emergency edition is English, so
/// it is used only when English was explicitly requested. A Spanish request
/// never silently changes language when the service is unavailable.
public struct FallbackHoroscopeRepository: HoroscopeRepository {
    private let primary: any HoroscopeRepository
    private let fallback: any HoroscopeRepository

    public init(
        primary: any HoroscopeRepository,
        fallback: any HoroscopeRepository
    ) {
        self.primary = primary
        self.fallback = fallback
    }

    public func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope {
        do {
            return try await primary.horoscope(for: sign, day: day, language: language)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            let primaryError = error
            try Task.checkCancellation()
            guard language == .english else {
                throw primaryError
            }
            return try await fallback.horoscope(for: sign, day: day, language: .english)
        }
    }
}
