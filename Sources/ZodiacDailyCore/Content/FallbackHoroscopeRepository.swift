import Foundation

/// Prefers fresh remote content and transparently falls back to the bundled
/// edition for offline use or any recoverable service/content failure.
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
            try Task.checkCancellation()
            if language == .spanish {
                do {
                    return try await primary.horoscope(
                        for: sign,
                        day: day,
                        language: .english
                    )
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    try Task.checkCancellation()
                }
            }
            return try await fallback.horoscope(for: sign, day: day, language: .english)
        }
    }
}
