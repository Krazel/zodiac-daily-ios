import Foundation
import XCTest
@testable import ZodiacDailyCore

final class FallbackHoroscopeRepositoryTests: XCTestCase {
    func testUsesPrimaryWhenItSucceeds() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let primaryReading = makeHoroscope(sign: .libra, day: day, version: 90)
        let fallbackReading = makeHoroscope(sign: .libra, day: day, version: 1)
        let repository = FallbackHoroscopeRepository(
            primary: StubHoroscopeRepository(result: .success(primaryReading)),
            fallback: StubHoroscopeRepository(result: .success(fallbackReading))
        )

        let result = try await repository.horoscope(for: .libra, day: day)

        XCTAssertEqual(result, primaryReading)
    }

    func testUsesBundledRepositoryWhenPrimaryFails() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let bundledRepository = try BundledHoroscopeRepository()
        let expected = try await bundledRepository.horoscope(for: .cancer, day: day)
        let repository = FallbackHoroscopeRepository(
            primary: StubHoroscopeRepository(result: .failure(.unavailable)),
            fallback: bundledRepository
        )

        let result = try await repository.horoscope(for: .cancer, day: day)

        XCTAssertEqual(result, expected)
        XCTAssertEqual(result.contentVersion, 1)
    }

    func testSurfacesFallbackFailureWhenBothRepositoriesFail() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let repository = FallbackHoroscopeRepository(
            primary: StubHoroscopeRepository(result: .failure(.unavailable)),
            fallback: StubHoroscopeRepository(result: .failure(.invalidFallback))
        )

        do {
            _ = try await repository.horoscope(for: .cancer, day: day)
            XCTFail("Expected fallback error")
        } catch {
            XCTAssertEqual(error as? StubRepositoryError, .invalidFallback)
        }
    }

    func testSpanishFailureRetriesRemoteEnglishBeforeBundledEnglish() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let english = makeHoroscope(sign: .cancer, day: day, version: 2)
        let primary = LanguageRecordingRepository(
            results: [
                .spanish: .failure(.unavailable),
                .english: .success(english)
            ]
        )
        let fallback = LanguageRecordingRepository(
            results: [.english: .failure(.invalidFallback)]
        )
        let repository = FallbackHoroscopeRepository(primary: primary, fallback: fallback)

        let result = try await repository.horoscope(
            for: .cancer,
            day: day,
            language: .spanish
        )

        XCTAssertEqual(result, english)
        let primaryLanguages = await primary.requestedLanguages()
        let fallbackLanguages = await fallback.requestedLanguages()
        XCTAssertEqual(primaryLanguages, [.spanish, .english])
        XCTAssertEqual(fallbackLanguages, [])
    }

    func testSpanishAndEnglishRemoteFailuresUseBundledEnglish() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let english = makeHoroscope(sign: .cancer, day: day, version: 1)
        let primary = LanguageRecordingRepository(
            results: [
                .spanish: .failure(.unavailable),
                .english: .failure(.unavailable)
            ]
        )
        let fallback = LanguageRecordingRepository(results: [.english: .success(english)])
        let repository = FallbackHoroscopeRepository(primary: primary, fallback: fallback)

        let result = try await repository.horoscope(
            for: .cancer,
            day: day,
            language: .spanish
        )

        XCTAssertEqual(result, english)
        let primaryLanguages = await primary.requestedLanguages()
        let fallbackLanguages = await fallback.requestedLanguages()
        XCTAssertEqual(primaryLanguages, [.spanish, .english])
        XCTAssertEqual(fallbackLanguages, [.english])
    }

    private func makeHoroscope(
        sign: ZodiacSign,
        day: LocalDayKey,
        version: Int
    ) -> DailyHoroscope {
        DailyHoroscope(
            sign: sign,
            day: day,
            headline: "Headline",
            reading: "Reading",
            contentVersion: version
        )
    }
}

private enum StubRepositoryError: Error, Equatable {
    case unavailable
    case invalidFallback
}

private actor StubHoroscopeRepository: HoroscopeRepository {
    private let result: Result<DailyHoroscope, StubRepositoryError>

    init(result: Result<DailyHoroscope, StubRepositoryError>) {
        self.result = result
    }

    func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope {
        try result.get()
    }
}

private actor LanguageRecordingRepository: HoroscopeRepository {
    private let results: [HoroscopeLanguage: Result<DailyHoroscope, StubRepositoryError>]
    private var languages: [HoroscopeLanguage] = []

    init(results: [HoroscopeLanguage: Result<DailyHoroscope, StubRepositoryError>]) {
        self.results = results
    }

    func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope {
        languages.append(language)
        return try results[language, default: .failure(.unavailable)].get()
    }

    func requestedLanguages() -> [HoroscopeLanguage] {
        languages
    }
}
