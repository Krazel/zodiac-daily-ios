import Foundation

/// Provider-authored daily metadata shown on the reverse of a card.
///
/// Daily values are optional so a bundled/offline edition can remain honest:
/// when FreeAstroAPI is unavailable the app preserves the reading, but does not
/// manufacture scores, lucky values, keywords, or lunar data.
public struct DailyCardDetails: Codable, Hashable, Sendable {
    public enum Source: String, Codable, Hashable, Sendable {
        case freeAstroAPIV2 = "freeastroapi-v2"
        case offline
    }

    public let source: Source
    public let focus: String
    public let keywords: [String]
    public let loveScore: Int?
    public let careerScore: Int?
    public let moneyScore: Int?
    public let healthScore: Int?
    public let luckyColor: String?
    public let luckyNumber: Int?
    public let moonSign: String?
    public let moonPhase: String?
    public let signEssence: String

    public init(
        source: Source,
        focus: String,
        keywords: [String],
        loveScore: Int?,
        careerScore: Int?,
        moneyScore: Int?,
        healthScore: Int?,
        luckyColor: String?,
        luckyNumber: Int?,
        moonSign: String?,
        moonPhase: String?,
        signEssence: String
    ) {
        self.source = source
        self.focus = focus
        self.keywords = keywords
        self.loveScore = loveScore
        self.careerScore = careerScore
        self.moneyScore = moneyScore
        self.healthScore = healthScore
        self.luckyColor = luckyColor
        self.luckyNumber = luckyNumber
        self.moonSign = moonSign
        self.moonPhase = moonPhase
        self.signEssence = signEssence
    }

    public static func provider(
        focus: String,
        keywords: [String],
        loveScore: Int,
        careerScore: Int,
        moneyScore: Int,
        healthScore: Int,
        luckyColor: String,
        luckyNumber: Int,
        moonSign: String,
        moonPhase: String,
        sign: ZodiacSign
    ) -> DailyCardDetails {
        DailyCardDetails(
            source: .freeAstroAPIV2,
            focus: focus,
            keywords: keywords,
            loveScore: loveScore,
            careerScore: careerScore,
            moneyScore: moneyScore,
            healthScore: healthScore,
            luckyColor: luckyColor,
            luckyNumber: luckyNumber,
            moonSign: moonSign,
            moonPhase: moonPhase,
            signEssence: signEssence(for: sign)
        )
    }

    public static func offlineFallback(for sign: ZodiacSign) -> DailyCardDetails {
        DailyCardDetails(
            source: .offline,
            focus: "Offline Edition",
            keywords: [],
            loveScore: nil,
            careerScore: nil,
            moneyScore: nil,
            healthScore: nil,
            luckyColor: nil,
            luckyNumber: nil,
            moonSign: nil,
            moonPhase: nil,
            signEssence: signEssence(for: sign)
        )
    }

    public var hasProviderData: Bool {
        source == .freeAstroAPIV2 &&
            !focus.isEmpty &&
            !keywords.isEmpty &&
            loveScore != nil && careerScore != nil && moneyScore != nil && healthScore != nil &&
            luckyColor != nil && luckyNumber != nil && moonSign != nil && moonPhase != nil
    }

    public static func signEssence(for sign: ZodiacSign) -> String {
        switch sign {
        case .aries:
            "Courageous beginnings guided by direct, vital energy."
        case .taurus:
            "Steady devotion, sensual wisdom, and the strength to cultivate."
        case .gemini:
            "Curious intelligence that connects ideas, people, and possibilities."
        case .cancer:
            "Protective sensitivity with a deep instinct for belonging."
        case .leo:
            "Creative warmth that leads through generosity and self-expression."
        case .virgo:
            "Discerning care that turns thoughtful details into useful order."
        case .libra:
            "Relational grace seeking beauty, fairness, and mutual understanding."
        case .scorpio:
            "Emotional depth with the courage to transform what is hidden."
        case .sagittarius:
            "Expansive truth-seeking shaped by freedom, meaning, and discovery."
        case .capricorn:
            "Patient ambition that builds lasting structure from clear purpose."
        case .aquarius:
            "Independent vision devoted to progress, community, and new patterns."
        case .pisces:
            "Compassionate imagination attuned to intuition, feeling, and wonder."
        }
    }

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
        case signEssence = "sign_essence"

        // Legacy v1 keys. Their generated daily prose is deliberately ignored.
        case love
        case work
        case wellBeing = "well_being"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedSource = try container.decodeIfPresent(Source.self, forKey: .source)

        if decodedSource == .freeAstroAPIV2 {
            source = .freeAstroAPIV2
            focus = try container.decode(String.self, forKey: .focus)
            keywords = try container.decode([String].self, forKey: .keywords)
            loveScore = try container.decode(Int.self, forKey: .loveScore)
            careerScore = try container.decode(Int.self, forKey: .careerScore)
            moneyScore = try container.decode(Int.self, forKey: .moneyScore)
            healthScore = try container.decode(Int.self, forKey: .healthScore)
            luckyColor = try container.decode(String.self, forKey: .luckyColor)
            luckyNumber = try container.decode(Int.self, forKey: .luckyNumber)
            moonSign = try container.decode(String.self, forKey: .moonSign)
            moonPhase = try container.decode(String.self, forKey: .moonPhase)
            signEssence = try container.decode(String.self, forKey: .signEssence)
        } else {
            source = .offline
            focus = "Offline Edition"
            keywords = []
            loveScore = nil
            careerScore = nil
            moneyScore = nil
            healthScore = nil
            luckyColor = nil
            luckyNumber = nil
            moonSign = nil
            moonPhase = nil
            signEssence = try container.decodeIfPresent(String.self, forKey: .signEssence) ?? ""
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(focus, forKey: .focus)
        try container.encode(keywords, forKey: .keywords)
        try container.encodeIfPresent(loveScore, forKey: .loveScore)
        try container.encodeIfPresent(careerScore, forKey: .careerScore)
        try container.encodeIfPresent(moneyScore, forKey: .moneyScore)
        try container.encodeIfPresent(healthScore, forKey: .healthScore)
        try container.encodeIfPresent(luckyColor, forKey: .luckyColor)
        try container.encodeIfPresent(luckyNumber, forKey: .luckyNumber)
        try container.encodeIfPresent(moonSign, forKey: .moonSign)
        try container.encodeIfPresent(moonPhase, forKey: .moonPhase)
        try container.encode(signEssence, forKey: .signEssence)
    }
}
