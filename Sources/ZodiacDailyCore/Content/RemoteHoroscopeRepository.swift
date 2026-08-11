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
    case mismatchedLanguage(expected: HoroscopeLanguage, received: HoroscopeLanguage)
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
        case .mismatchedLanguage(let expected, let received):
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

    public func horoscope(
        for sign: ZodiacSign,
        day: LocalDayKey,
        language: HoroscopeLanguage
    ) async throws -> DailyHoroscope {
        try Task.checkCancellation()
        let request = try makeRequest(day: day, language: language)
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

        guard (1...3).contains(payload.schemaVersion),
              !payload.generatedAt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !payload.provider.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              payload.horoscopes.count == ZodiacSign.allCases.count,
              payload.horoscopes.allSatisfy({
                  $0.isValid(
                      schemaVersion: payload.schemaVersion,
                      language: payload.language
                  )
              })
        else {
            throw RemoteHoroscopeRepositoryError.invalidPayload
        }
        guard payload.requestedDate == day else {
            throw RemoteHoroscopeRepositoryError.mismatchedDay(expected: day, received: payload.requestedDate)
        }
        guard payload.language == language else {
            throw RemoteHoroscopeRepositoryError.mismatchedLanguage(
                expected: language,
                received: payload.language
            )
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

        let details = content.details.map {
            DailyCardDetails.provider(
                focus: $0.focus.trimmingCharacters(in: .whitespacesAndNewlines),
                keywords: $0.keywords.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) },
                loveScore: $0.loveScore,
                careerScore: $0.careerScore,
                moneyScore: $0.moneyScore,
                healthScore: $0.healthScore,
                luckyColor: $0.luckyColor.trimmingCharacters(in: .whitespacesAndNewlines),
                luckyNumber: $0.luckyNumber,
                moonSign: $0.moonSign.trimmingCharacters(in: .whitespacesAndNewlines),
                moonPhase: $0.moonPhase.trimmingCharacters(in: .whitespacesAndNewlines),
                sign: sign,
                language: language
            )
        }

        return DailyHoroscope(
            sign: sign,
            day: day,
            language: language,
            headline: content.normalizedHeadline,
            reading: content.normalizedReading,
            details: details,
            contentVersion: content.contentVersion
        )
    }

    private func makeRequest(day: LocalDayKey, language: HoroscopeLanguage) throws -> URLRequest {
        let url = baseURL
            .appendingPathComponent("v1", isDirectory: true)
            .appendingPathComponent("daily", isDirectory: true)
            .appendingPathComponent(day.rawValue, isDirectory: false)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw RemoteHoroscopeRepositoryError.invalidResponse
        }
        components.queryItems = [URLQueryItem(name: "lang", value: language.rawValue)]
        guard let localizedURL = components.url else {
            throw RemoteHoroscopeRepositoryError.invalidResponse
        }

        var request = URLRequest(url: localizedURL)
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
    let language: HoroscopeLanguage
    let generatedAt: String
    let stale: Bool
    let provider: String
    let horoscopes: [RemoteSignContent]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case requestedDate = "requested_date"
        case contentDate = "content_date"
        case language
        case generatedAt = "generated_at"
        case stale
        case provider
        case horoscopes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        requestedDate = try container.decode(LocalDayKey.self, forKey: .requestedDate)
        contentDate = try container.decode(LocalDayKey.self, forKey: .contentDate)

        if let decodedLanguage = try container.decodeIfPresent(
            HoroscopeLanguage.self,
            forKey: .language
        ) {
            language = decodedLanguage
        } else if schemaVersion <= 2 {
            // The original normalized contract was English-only and did not
            // carry a language field.
            language = .english
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.language,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Schema 3 requires a content language."
                )
            )
        }

        generatedAt = try container.decode(String.self, forKey: .generatedAt)
        stale = try container.decode(Bool.self, forKey: .stale)
        provider = try container.decode(String.self, forKey: .provider)
        horoscopes = try container.decode([RemoteSignContent].self, forKey: .horoscopes)
    }
}

private struct RemoteSignContent: Decodable, Sendable {
    private static let maximumHeadlineCharacterCount = 52
    private static let maximumSpanishHeadlineCharacterCount = 72
    private static let minimumReadingCharacterCount = 40
    // Current FreeAstroAPI editions are typically 324-382 characters. Keep a
    // bounded production contract without rejecting the real daily feed.
    private static let maximumReadingCharacterCount = 500
    private static let maximumSpanishReadingCharacterCount = 700

    let sign: ZodiacSign
    let headline: String
    let reading: String
    let details: RemoteProviderDetails?
    let contentVersion: Int

    private enum CodingKeys: String, CodingKey {
        case sign
        case headline
        case reading
        case details
        case contentVersion = "content_version"
    }

    var normalizedHeadline: String {
        headline.normalizedCardCopy
    }

    var normalizedReading: String {
        reading.normalizedCardCopy
    }

    func isValid(schemaVersion: Int, language: HoroscopeLanguage) -> Bool {
        let headlineLimit = language == .spanish
            ? Self.maximumSpanishHeadlineCharacterCount
            : Self.maximumHeadlineCharacterCount
        let readingLimit = language == .spanish
            ? Self.maximumSpanishReadingCharacterCount
            : Self.maximumReadingCharacterCount
        let baseIsValid = !normalizedHeadline.isEmpty &&
            normalizedHeadline.count <= headlineLimit &&
            (Self.minimumReadingCharacterCount...readingLimit)
                .contains(normalizedReading.count) &&
            contentVersion > 0
        if schemaVersion >= 2 {
            return baseIsValid && details?.isValid == true
        }
        return baseIsValid
    }
}

private extension String {
    /// Remote prose is rendered as continuous card copy. Collapse spaces,
    /// tabs, and line breaks before validating so layout bounds apply to the
    /// exact text returned to the UI rather than to transport formatting.
    var normalizedCardCopy: String {
        split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }
}

private struct RemoteProviderDetails: Decodable, Sendable {
    let source: String
    let focus: String
    let keywords: [String]
    let loveScore: Int
    let careerScore: Int
    let moneyScore: Int
    let healthScore: Int
    let luckyColor: String
    let luckyNumber: Int
    let moonSign: String
    let moonPhase: String

    private enum CodingKeys: String, CodingKey {
        case source
        case focus
        case keywords
        case loveScore = "love_score"
        case careerScore = "career_score"
        case moneyScore = "money_score"
        case healthScore = "health_score"
        case luckyColor = "lucky_color"
        case luckyNumber = "lucky_number"
        case moonSign = "moon_sign"
        case moonPhase = "moon_phase"
    }

    var isValid: Bool {
        let strings = [focus, luckyColor, moonSign, moonPhase]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let cleanedKeywords = keywords.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let scores = [loveScore, careerScore, moneyScore, healthScore]

        return source == DailyCardDetails.Source.freeAstroAPIV2.rawValue &&
            strings.allSatisfy { !$0.isEmpty } &&
            focus.count <= 100 && luckyColor.count <= 32 &&
            moonSign.count <= 40 && moonPhase.count <= 40 &&
            (1...8).contains(cleanedKeywords.count) &&
            cleanedKeywords.allSatisfy { !$0.isEmpty && $0.count <= 40 } &&
            Set(cleanedKeywords.map { $0.lowercased() }).count == cleanedKeywords.count &&
            scores.allSatisfy { (0...100).contains($0) } &&
            (1...99).contains(luckyNumber)
    }
}
