import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Minimal, injectable HTTP boundary used by the remote repository.
/// Production uses URLSession; tests can provide a transport without touching
/// the network.
public protocol HoroscopeHTTPTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

public struct URLSessionHoroscopeTransport: HoroscopeHTTPTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteHoroscopeRepositoryError.invalidResponse
        }
        return (data, httpResponse)
    }
}

public enum RemoteHoroscopeRepositoryError: Error, Equatable, Sendable {
    case insecureBaseURL
    case transportFailure
    case invalidResponse
    case httpStatus(Int)
    case invalidPayload
    case mismatchedDay(expected: LocalDayKey, received: LocalDayKey)
    case missingContent(ZodiacSign)
}

extension RemoteHoroscopeRepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .insecureBaseURL:
            "The horoscope service address must be a secure HTTPS URL."
        case .transportFailure:
            "The daily horoscope service could not be reached."
        case .invalidResponse:
            "The daily horoscope service returned an invalid response."
        case .httpStatus(let status):
            "The daily horoscope service returned HTTP status \(status)."
        case .invalidPayload:
            "The daily horoscope service returned invalid content."
        case .mismatchedDay(let expected, let received):
            "The daily horoscope service returned \(received.rawValue) instead of \(expected.rawValue)."
        case .missingContent(let sign):
            "The daily horoscope service returned no content for \(sign.displayName)."
        }
    }
}

/// Loads a normalized daily edition from Zodiac Daily's own endpoint.
///
/// The app sends no FreeAstroAPI credential. That credential belongs only in
/// the server-side adapter, which returns the documented normalized contract.
public struct RemoteHoroscopeRepository: HoroscopeRepository {
    private let baseURL: URL
    private let transport: any HoroscopeHTTPTransport

    public init(
        baseURL: URL,
        transport: any HoroscopeHTTPTransport = URLSessionHoroscopeTransport()
    ) throws {
        guard Self.isSecureBaseURL(baseURL) else {
            throw RemoteHoroscopeRepositoryError.insecureBaseURL
        }
        self.baseURL = baseURL
        self.transport = transport
    }

    public func horoscope(for sign: ZodiacSign, day: LocalDayKey) async throws -> DailyHoroscope {
        try Task.checkCancellation()
        let request = try makeRequest(day: day)
        let data: Data
        let response: HTTPURLResponse

        do {
            (data, response) = try await transport.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as RemoteHoroscopeRepositoryError {
            throw error
        } catch {
            try Task.checkCancellation()
            throw RemoteHoroscopeRepositoryError.transportFailure
        }
        try Task.checkCancellation()

        guard (200...299).contains(response.statusCode) else {
            throw RemoteHoroscopeRepositoryError.httpStatus(response.statusCode)
        }

        let payload: DailyPayload
        do {
            payload = try JSONDecoder().decode(DailyPayload.self, from: data)
        } catch {
            throw RemoteHoroscopeRepositoryError.invalidPayload
        }

        guard payload.schemaVersion == 1,
              !payload.generatedAt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !payload.provider.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              payload.horoscopes.count == ZodiacSign.allCases.count,
              payload.horoscopes.allSatisfy(\.isValid)
        else {
            throw RemoteHoroscopeRepositoryError.invalidPayload
        }
        guard payload.requestedDate == day else {
            throw RemoteHoroscopeRepositoryError.mismatchedDay(expected: day, received: payload.requestedDate)
        }
        guard payload.contentDate == payload.requestedDate else {
            throw RemoteHoroscopeRepositoryError.invalidPayload
        }

        var readingsBySign: [ZodiacSign: RemoteSignContent] = [:]
        for content in payload.horoscopes {
            guard readingsBySign.updateValue(content, forKey: content.sign) == nil else {
                throw RemoteHoroscopeRepositoryError.invalidPayload
            }
        }
        guard Set(readingsBySign.keys) == Set(ZodiacSign.allCases),
              let content = readingsBySign[sign]
        else {
            throw RemoteHoroscopeRepositoryError.missingContent(sign)
        }

        return DailyHoroscope(
            sign: sign,
            day: day,
            headline: content.headline.trimmingCharacters(in: .whitespacesAndNewlines),
            reading: content.reading.trimmingCharacters(in: .whitespacesAndNewlines),
            contentVersion: content.contentVersion
        )
    }

    private func makeRequest(day: LocalDayKey) throws -> URLRequest {
        let url = baseURL
            .appendingPathComponent("v1", isDirectory: true)
            .appendingPathComponent("daily", isDirectory: true)
            .appendingPathComponent(day.rawValue, isDirectory: false)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private static func isSecureBaseURL(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        return components.scheme?.lowercased() == "https" &&
            components.host?.isEmpty == false &&
            components.user == nil &&
            components.password == nil &&
            components.query == nil &&
            components.fragment == nil
    }
}

private struct DailyPayload: Decodable, Sendable {
    let schemaVersion: Int
    let requestedDate: LocalDayKey
    let contentDate: LocalDayKey
    let generatedAt: String
    let stale: Bool
    let provider: String
    let horoscopes: [RemoteSignContent]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case requestedDate = "requested_date"
        case contentDate = "content_date"
        case generatedAt = "generated_at"
        case stale
        case provider
        case horoscopes
    }
}

private struct RemoteSignContent: Decodable, Sendable {
    let sign: ZodiacSign
    let headline: String
    let reading: String
    let contentVersion: Int

    private enum CodingKeys: String, CodingKey {
        case sign
        case headline
        case reading
        case contentVersion = "content_version"
    }

    var isValid: Bool {
        let trimmedHeadline = headline.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReading = reading.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedHeadline.isEmpty &&
            trimmedReading.count >= 40 &&
            trimmedHeadline.count <= 160 &&
            trimmedReading.count <= 2_000 &&
            contentVersion > 0
    }
}
