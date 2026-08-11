import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
@testable import ZodiacDailyCore

final class RemoteHoroscopeRepositoryTests: XCTestCase {
    func testDecodesNormalizedDailyContractAndBuildsExpectedRequest() async throws {
        let transport = RecordingTransport(data: makePayload())
        let repository = try RemoteHoroscopeRepository(
            baseURL: try XCTUnwrap(URL(string: "https://daily.example/api")),
            transport: transport
        )
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let horoscope = try await repository.horoscope(for: .scorpio, day: day)

        XCTAssertEqual(horoscope.sign, .scorpio)
        XCTAssertEqual(horoscope.day, day)
        XCTAssertEqual(horoscope.language, .english)
        XCTAssertEqual(horoscope.headline, "Scorpio headline")
        XCTAssertEqual(
            horoscope.reading,
            "A considered Scorpio reading with enough detail for a complete daily card."
        )
        XCTAssertEqual(
            horoscope.details,
            DailyCardDetails.provider(
                focus: "Scorpio focus",
                keywords: ["Empathy", "Flow", "Imagination"],
                loveScore: 83,
                careerScore: 89,
                moneyScore: 85,
                healthScore: 78,
                luckyColor: "Silver",
                luckyNumber: 61,
                moonSign: "Capricorn",
                moonPhase: "Last Quarter",
                sign: .scorpio
            )
        )
        XCTAssertEqual(horoscope.contentVersion, 20_260_809)

        let recordedRequest = await transport.lastRequest()
        let request = try XCTUnwrap(recordedRequest)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.url?.path, "/api/v1/daily/2026-08-09")
        XCTAssertEqual(request.url?.query, "lang=en")
    }

    func testRequestsAndDecodesSpanishEdition() async throws {
        let transport = RecordingTransport(data: makePayload(language: "es"))
        let repository = try RemoteHoroscopeRepository(
            baseURL: try XCTUnwrap(URL(string: "https://daily.example/api")),
            transport: transport
        )
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let horoscope = try await repository.horoscope(
            for: .scorpio,
            day: day,
            language: .spanish
        )

        XCTAssertEqual(horoscope.language, .spanish)
        XCTAssertEqual(
            horoscope.details.signEssence,
            "Intenso · Perceptivo · Transformador"
        )
        let recordedRequest = await transport.lastRequest()
        let request = try XCTUnwrap(recordedRequest)
        XCTAssertEqual(request.url?.query, "lang=es")
    }

    func testRejectsPayloadForDifferentLanguage() async throws {
        let repository = try makeRepository(data: makePayload(language: "en"))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        await assertThrows(.mismatchedLanguage(expected: .spanish, received: .english)) {
            try await repository.horoscope(for: .aries, day: day, language: .spanish)
        }
    }

    func testLegacySchemaWithoutLanguageMigratesToEnglish() async throws {
        let repository = try makeRepository(
            data: makePayload(schemaVersion: 2, language: nil)
        )
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let horoscope = try await repository.horoscope(
            for: .aries,
            day: day,
            language: .english
        )

        XCTAssertEqual(horoscope.language, .english)
    }

    func testSchemaThreeRequiresLanguage() async throws {
        let repository = try makeRepository(
            data: makePayload(schemaVersion: 3, language: nil)
        )
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        await assertThrows(.invalidPayload) {
            try await repository.horoscope(for: .aries, day: day)
        }
    }

    func testRejectsPayloadForDifferentDay() async throws {
        let requestedDay = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let receivedDay = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-10"))
        let repository = try makeRepository(data: makePayload(requestedDate: receivedDay.rawValue))

        do {
            _ = try await repository.horoscope(for: .aries, day: requestedDay)
            XCTFail("Expected a mismatched-day error")
        } catch {
            XCTAssertEqual(
                error as? RemoteHoroscopeRepositoryError,
                .mismatchedDay(expected: requestedDay, received: receivedDay)
            )
        }
    }

    func testRejectsIncompleteTwelveSignContract() async throws {
        var horoscopes = makeHoroscopes()
        horoscopes.removeLast()
        let repository = try makeRepository(data: makePayload(horoscopes: horoscopes))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        await assertThrows(.invalidPayload) {
            try await repository.horoscope(for: .aries, day: day)
        }
    }

    func testRejectsBlankContent() async throws {
        var horoscopes = makeHoroscopes()
        horoscopes[0]["headline"] = " "
        let repository = try makeRepository(data: makePayload(horoscopes: horoscopes))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        await assertThrows(.invalidPayload) {
            try await repository.horoscope(for: .aries, day: day)
        }
    }

    func testNormalizesWhitespaceInAcceptedCardCopy() async throws {
        var horoscopes = makeHoroscopes()
        horoscopes[0]["headline"] = "  A   measured\nstep  "
        horoscopes[0]["reading"] = "  A\tclear  daily\nreading keeps every useful thought while removing transport spacing.  "
        let repository = try makeRepository(data: makePayload(horoscopes: horoscopes))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let horoscope = try await repository.horoscope(for: .aries, day: day)

        XCTAssertEqual(horoscope.headline, "A measured step")
        XCTAssertEqual(
            horoscope.reading,
            "A clear daily reading keeps every useful thought while removing transport spacing."
        )
    }

    func testAcceptsExactCardCopyCharacterLimits() async throws {
        var horoscopes = makeHoroscopes()
        horoscopes[0]["headline"] = String(repeating: "H", count: 52)
        horoscopes[0]["reading"] = String(repeating: "R", count: 500)
        let repository = try makeRepository(data: makePayload(horoscopes: horoscopes))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let horoscope = try await repository.horoscope(for: .aries, day: day)

        XCTAssertEqual(horoscope.headline.count, 52)
        XCTAssertEqual(horoscope.reading.count, 500)
    }

    func testSpanishContractAcceptsItsTranslationExpansionLimits() async throws {
        var horoscopes = makeHoroscopes()
        horoscopes[0]["headline"] = String(repeating: "H", count: 72)
        horoscopes[0]["reading"] = String(repeating: "R", count: 700)
        let repository = try makeRepository(
            data: makePayload(schemaVersion: 3, language: "es", horoscopes: horoscopes)
        )
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let horoscope = try await repository.horoscope(
            for: .aries,
            day: day,
            language: .spanish
        )

        XCTAssertEqual(horoscope.headline.count, 72)
        XCTAssertEqual(horoscope.reading.count, 700)
    }

    func testRejectsHeadlineBeyondFixedCardLimit() async throws {
        var horoscopes = makeHoroscopes()
        horoscopes[0]["headline"] = String(repeating: "H", count: 53)
        let repository = try makeRepository(data: makePayload(horoscopes: horoscopes))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        await assertThrows(.invalidPayload) {
            try await repository.horoscope(for: .aries, day: day)
        }
    }

    func testRejectsReadingBeyondFixedCardLimitWithoutTruncating() async throws {
        var horoscopes = makeHoroscopes()
        horoscopes[0]["reading"] = String(repeating: "R", count: 501)
        let repository = try makeRepository(data: makePayload(horoscopes: horoscopes))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        await assertThrows(.invalidPayload) {
            try await repository.horoscope(for: .aries, day: day)
        }
    }

    func testSchemaOneWithoutDetailsUsesHonestOfflineFallback() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let repository = try makeRepository(
            data: makePayload(schemaVersion: 1, horoscopes: makeHoroscopes(includeDetails: false))
        )

        let horoscope = try await repository.horoscope(for: .pisces, day: day)

        XCTAssertEqual(horoscope.details, DailyCardDetails.offlineFallback(for: .pisces))
        XCTAssertFalse(horoscope.details.hasProviderData)
    }

    func testSchemaTwoRejectsMissingOrMalformedProviderDetails() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let missingRepository = try makeRepository(
            data: makePayload(
                schemaVersion: 2,
                horoscopes: makeHoroscopes(includeDetails: false)
            )
        )
        await assertThrows(.invalidPayload) {
            try await missingRepository.horoscope(for: .aries, day: day)
        }

        var malformed = makeHoroscopes()
        var details = malformed[0]["details"] as! [String: Any]
        details["love_score"] = 101
        malformed[0]["details"] = details
        let malformedRepository = try makeRepository(
            data: makePayload(schemaVersion: 2, horoscopes: malformed)
        )
        await assertThrows(.invalidPayload) {
            try await malformedRepository.horoscope(for: .aries, day: day)
        }
    }

    func testMapsHTTPAndTransportErrors() async throws {
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))
        let httpRepository = try RemoteHoroscopeRepository(
            baseURL: try XCTUnwrap(URL(string: "https://daily.example")),
            transport: RecordingTransport(data: Data(), statusCode: 503)
        )
        let failedRepository = try RemoteHoroscopeRepository(
            baseURL: try XCTUnwrap(URL(string: "https://daily.example")),
            transport: RecordingTransport(errorCode: .notConnectedToInternet)
        )

        await assertThrows(.httpStatus(503)) {
            try await httpRepository.horoscope(for: .leo, day: day)
        }
        await assertThrows(.transportFailure) {
            try await failedRepository.horoscope(for: .leo, day: day)
        }
    }

    func testRejectsLastValidContentFromAnotherDay() async throws {
        let repository = try makeRepository(
            data: makePayload(contentDate: "2026-08-08", stale: true)
        )
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        await assertThrows(.invalidPayload) {
            try await repository.horoscope(for: .pisces, day: day)
        }
    }

    func testAcceptsStaleMarkerOnlyWhenContentDateStillMatches() async throws {
        let repository = try makeRepository(data: makePayload(stale: true))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        let horoscope = try await repository.horoscope(for: .pisces, day: day)
        XCTAssertEqual(horoscope.day, day)
        XCTAssertEqual(horoscope.sign, .pisces)
    }

    func testRejectsDuplicateSignEntries() async throws {
        var horoscopes = makeHoroscopes()
        horoscopes[11] = horoscopes[0]
        let repository = try makeRepository(data: makePayload(horoscopes: horoscopes))
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        await assertThrows(.invalidPayload) {
            try await repository.horoscope(for: .aries, day: day)
        }
    }

    func testRejectsInsecureOrCredentialBearingBaseURLs() throws {
        XCTAssertThrowsError(
            try RemoteHoroscopeRepository(baseURL: XCTUnwrap(URL(string: "http://daily.example")))
        ) { error in
            XCTAssertEqual(error as? RemoteHoroscopeRepositoryError, .insecureBaseURL)
        }
        XCTAssertThrowsError(
            try RemoteHoroscopeRepository(baseURL: XCTUnwrap(URL(string: "https://key@daily.example")))
        ) { error in
            XCTAssertEqual(error as? RemoteHoroscopeRepositoryError, .insecureBaseURL)
        }
    }

    func testMapsCancelledURLRequestToCancellationError() async throws {
        let repository = try RemoteHoroscopeRepository(
            baseURL: try XCTUnwrap(URL(string: "https://daily.example")),
            transport: RecordingTransport(errorCode: .cancelled)
        )
        let day = try XCTUnwrap(LocalDayKey(rawValue: "2026-08-09"))

        do {
            _ = try await repository.horoscope(for: .virgo, day: day)
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }

    private func makeRepository(data: Data) throws -> RemoteHoroscopeRepository {
        try RemoteHoroscopeRepository(
            baseURL: XCTUnwrap(URL(string: "https://daily.example")),
            transport: RecordingTransport(data: data)
        )
    }

    private func makePayload(
        schemaVersion: Int = 3,
        requestedDate: String = "2026-08-09",
        contentDate: String = "2026-08-09",
        language: String? = "en",
        stale: Bool = false,
        horoscopes: [[String: Any]]? = nil
    ) -> Data {
        var object: [String: Any] = [
            "schema_version": schemaVersion,
            "requested_date": requestedDate,
            "content_date": contentDate,
            "generated_at": "2026-08-09T00:15:00.000Z",
            "stale": stale,
            "provider": stale ? "freeastroapi:last-valid" : "freeastroapi",
            "horoscopes": horoscopes ?? makeHoroscopes()
        ]
        if let language {
            object["language"] = language
        }
        return try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    }

    private func makeHoroscopes(includeDetails: Bool = true) -> [[String: Any]] {
        ZodiacSign.allCases.map { sign in
            var horoscope: [String: Any] = [
                "sign": sign.rawValue,
                "headline": "\(sign.displayName) headline",
                "reading": "A considered \(sign.displayName) reading with enough detail for a complete daily card.",
                "content_version": 20_260_809
            ]
            if includeDetails {
                horoscope["details"] = [
                    "source": "freeastroapi-v2",
                    "focus": "\(sign.displayName) focus",
                    "keywords": ["Empathy", "Flow", "Imagination"],
                    "love_score": 83,
                    "career_score": 89,
                    "money_score": 85,
                    "health_score": 78,
                    "lucky_color": "Silver",
                    "lucky_number": 61,
                    "moon_sign": "Capricorn",
                    "moon_phase": "Last Quarter"
                ]
            }
            return horoscope
        }
    }

    private func assertThrows(
        _ expected: RemoteHoroscopeRepositoryError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected \(expected)")
        } catch {
            XCTAssertEqual(error as? RemoteHoroscopeRepositoryError, expected)
        }
    }
}

private actor RecordingTransport: HoroscopeHTTPTransport {
    private let data: Data
    private let statusCode: Int
    private let errorCode: URLError.Code?
    private var requests: [URLRequest] = []

    init(data: Data = Data(), statusCode: Int = 200, errorCode: URLError.Code? = nil) {
        self.data = data
        self.statusCode = statusCode
        self.errorCode = errorCode
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        if let errorCode {
            throw URLError(errorCode)
        }
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data, response)
    }

    func lastRequest() -> URLRequest? {
        requests.last
    }
}
