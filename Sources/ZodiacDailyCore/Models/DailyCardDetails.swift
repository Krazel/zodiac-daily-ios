import Foundation

/// The structured, non-personal guidance shown on the reverse of a daily card.
///
/// Values are part of the immutable daily edition, so saving a card also saves
/// the exact reverse shown that day. No birth time, location, account, or
/// device identifier participates in the fallback.
public struct DailyCardDetails: Codable, Hashable, Sendable {
    public let love: String
    public let work: String
    public let wellBeing: String
    public let luckyColor: String
    public let luckyNumber: Int
    public let signEssence: String

    public init(
        love: String,
        work: String,
        wellBeing: String,
        luckyColor: String,
        luckyNumber: Int,
        signEssence: String
    ) {
        self.love = love
        self.work = work
        self.wellBeing = wellBeing
        self.luckyColor = luckyColor
        self.luckyNumber = luckyNumber
        self.signEssence = signEssence
    }

    private enum CodingKeys: String, CodingKey {
        case love
        case work
        case wellBeing = "well_being"
        case luckyColor = "lucky_color"
        case luckyNumber = "lucky_number"
        case signEssence = "sign_essence"
    }

    /// Versioned and stable across app launches and Swift processes.
    /// Used by current remote v1 editions and legacy saved-card archives.
    public static func deterministicFallback(
        for sign: ZodiacSign,
        day: LocalDayKey
    ) -> DailyCardDetails {
        let baseSeed = "daily-card-details:v1|\(sign.rawValue)|\(day.rawValue)"

        return DailyCardDetails(
            love: loveOptions[StableDailyDetailsSelector.index(seed: baseSeed + "|love", count: loveOptions.count)],
            work: workOptions[StableDailyDetailsSelector.index(seed: baseSeed + "|work", count: workOptions.count)],
            wellBeing: wellBeingOptions[
                StableDailyDetailsSelector.index(seed: baseSeed + "|well-being", count: wellBeingOptions.count)
            ],
            luckyColor: luckyColors[
                StableDailyDetailsSelector.index(seed: baseSeed + "|lucky-color", count: luckyColors.count)
            ],
            luckyNumber: StableDailyDetailsSelector.index(seed: baseSeed + "|lucky-number", count: 99) + 1,
            signEssence: essence(for: sign)
        )
    }

    private static let loveOptions = [
        "Lead with warmth and let an honest answer arrive in its own time.",
        "A small gesture of attention says more than a perfectly chosen speech.",
        "Make room for reciprocity; care should be able to travel both ways.",
        "Say what you need gently and listen for the need beneath the reply.",
        "Connection grows when you choose curiosity over a quick conclusion.",
        "Protect the bond that feels calm, clear, and generous rather than urgent.",
        "Let affection be practical today: notice, remember, and follow through.",
        "A sincere boundary can bring more closeness than another silent compromise."
    ]

    private static let workOptions = [
        "Give the most valuable task one uninterrupted stretch of attention.",
        "Clarify the next deliverable before adding anything else to the plan.",
        "A useful conversation can remove the obstacle that effort alone cannot.",
        "Finish the smallest meaningful piece and let visible progress build momentum.",
        "Choose durable work over busy work; the difference will be clear by evening.",
        "Review one assumption before committing more energy to the current route.",
        "Your steady judgment matters more today than speed or a dramatic gesture.",
        "Share the idea in a concrete form so others can help it become stronger."
    ]

    private static let wellBeingOptions = [
        "Create a quiet pause between obligations and let your body reset the pace.",
        "A simple meal, fresh air, and an earlier finish will restore more than pushing through.",
        "Protect your attention from unnecessary noise and return to one grounding ritual.",
        "Move gently enough to notice where tension is asking for care rather than force.",
        "Balance effort with something sensory and calm: music, water, warmth, or open sky.",
        "Keep one promise to your future self by making rest part of today’s plan.",
        "Name what is draining you, then reduce one avoidable demand without guilt.",
        "A slower transition between tasks will help your energy last through the day."
    ]

    private static let luckyColors = [
        "Amber",
        "Celestial Blue",
        "Deep Violet",
        "Forest Green",
        "Moon Silver",
        "Ocean Teal",
        "Rose Quartz",
        "Saffron",
        "Soft Ivory",
        "Terracotta"
    ]

    private static func essence(for sign: ZodiacSign) -> String {
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
}

private enum StableDailyDetailsSelector {
    /// FNV-1a avoids Swift Hasher's intentionally process-random seed.
    static func index(seed: String, count: Int) -> Int {
        precondition(count > 0)
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return Int(hash % UInt64(count))
    }
}
