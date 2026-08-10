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
        XCTAssertEqual(horoscope.headline, "Scorpio headline")
        XCTAssertEqual(
            horoscope.reading,
            "A considered Scorpio reading with enough detail for a complete daily card."
        )
        XCTAssertEqual(
            horoscope.details,
            DailyCardDetails.deterministicFallback(for: .scorpio, day: day)
        )
        XCTAssertEqual(horoscope.contentVersion, 20_260_809)

        let recordedRequest = await transport.lastRequest()
        let request = try XCTUnwrap(recordedRequest)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.url?.path, "/api/v1/daily/2026-08-09")
        XCTAssertNil(request.url?.query)
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
        requestedDate: String = "2026-08-09",
        contentDate: String = "2026-08-09",
        stale: Bool = false,
        horoscopes: [[String: Any]]? = nil
    ) -> Data {
        let object: [String: Any] = [
            "schema_version": 1,
            "requested_date": requestedDate,
            "content_date": contentDate,
            "generated_at": "2026-08-09T00:15:00.000Z",
            "stale": stale,
            "provider": stale ? "freeastroapi:last-valid" : "freeastroapi",
            "horoscopes": horoscopes ?? makeHoroscopes()
        ]
        return try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    }

    private func makeHoroscopes() -> [[String: Any]] {
        ZodiacSign.allCases.map { sign in
            [
                "sign": sign.rawValue,
                "headline": "\(sign.displayName) headline",
                "reading": "A considered \(sign.displayName) reading with enough detail for a complete daily card.",
                "content_version": 20_260_809
            ]
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
