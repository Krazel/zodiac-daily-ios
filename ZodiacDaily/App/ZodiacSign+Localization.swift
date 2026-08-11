import Foundation
import SwiftUI
import ZodiacDailyCore

extension ZodiacSign {
    var localizedDisplayName: LocalizedStringKey {
        switch self {
        case .aries: "zodiac.aries"
        case .taurus: "zodiac.taurus"
        case .gemini: "zodiac.gemini"
        case .cancer: "zodiac.cancer"
        case .leo: "zodiac.leo"
        case .virgo: "zodiac.virgo"
        case .libra: "zodiac.libra"
        case .scorpio: "zodiac.scorpio"
        case .sagittarius: "zodiac.sagittarius"
        case .capricorn: "zodiac.capricorn"
        case .aquarius: "zodiac.aquarius"
        case .pisces: "zodiac.pisces"
        }
    }

    func localizedDisplayName(locale: Locale) -> String {
        switch self {
        case .aries: String(localized: "zodiac.aries", locale: locale)
        case .taurus: String(localized: "zodiac.taurus", locale: locale)
        case .gemini: String(localized: "zodiac.gemini", locale: locale)
        case .cancer: String(localized: "zodiac.cancer", locale: locale)
        case .leo: String(localized: "zodiac.leo", locale: locale)
        case .virgo: String(localized: "zodiac.virgo", locale: locale)
        case .libra: String(localized: "zodiac.libra", locale: locale)
        case .scorpio: String(localized: "zodiac.scorpio", locale: locale)
        case .sagittarius: String(localized: "zodiac.sagittarius", locale: locale)
        case .capricorn: String(localized: "zodiac.capricorn", locale: locale)
        case .aquarius: String(localized: "zodiac.aquarius", locale: locale)
        case .pisces: String(localized: "zodiac.pisces", locale: locale)
        }
    }
}
