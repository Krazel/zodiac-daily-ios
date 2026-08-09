import Foundation

/// Produces a stable sign/day edition from authored content shipped in the app.
/// No network, account, device identifier, or random process state is used.
public struct BundledHoroscopeRepository: HoroscopeRepository {
    private let catalog: HoroscopeCatalog

    public init() throws {
        let resourceName = "zodiac_daily_content"
        guard let url = Bundle.module.url(forResource: resourceName, withExtension: "json") else {
            throw HoroscopeRepositoryError.resourceMissing("\(resourceName).json")
        }
        try self.init(data: Data(contentsOf: url))
    }

    /// Supports tests and future locally cached catalogs without changing the
    /// repository contract.
    public init(data: Data) throws {
        do {
            let decoded = try JSONDecoder().decode(HoroscopeCatalog.self, from: data)
            guard decoded.version > 0,
                  Set(decoded.signs.keys) == Set(ZodiacSign.allCases.map(\.rawValue)),
                  decoded.signs.values.allSatisfy(\.isValid)
            else {
                throw HoroscopeRepositoryError.invalidResource
            }
            self.catalog = decoded
        } catch let error as HoroscopeRepositoryError {
            throw error
        } catch {
            throw HoroscopeRepositoryError.invalidResource
        }
    }

    public func horoscope(for sign: ZodiacSign, day: LocalDayKey) async throws -> DailyHoroscope {
        guard let content = catalog.signs[sign.rawValue] else {
            throw HoroscopeRepositoryError.missingContent(sign)
        }

        let seed = "v\(catalog.version)|\(sign.rawValue)|\(day.rawValue)"
        let headlineIndex = StableSelector.index(seed: seed + "|headline", count: content.headlines.count)
        let readingIndex = StableSelector.index(seed: seed + "|reading", count: content.readings.count)

        return DailyHoroscope(
            sign: sign,
            day: day,
            headline: content.headlines[headlineIndex],
            reading: content.readings[readingIndex],
            contentVersion: catalog.version
        )
    }
}

private struct HoroscopeCatalog: Decodable, Sendable {
    let version: Int
    let signs: [String: SignContent]
}

private struct SignContent: Decodable, Sendable {
    let headlines: [String]
    let readings: [String]

    var isValid: Bool {
        !headlines.isEmpty &&
        !readings.isEmpty &&
        headlines.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } &&
        readings.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}

private enum StableSelector {
    /// FNV-1a is intentionally implemented here instead of Swift's `Hasher`,
    /// whose seed changes between processes.
    static func index(seed: String, count: Int) -> Int {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return Int(hash % UInt64(count))
    }
}
