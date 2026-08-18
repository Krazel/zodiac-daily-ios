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
        case .aries: appLocalized("zodiac.aries", locale: locale)
        case .taurus: appLocalized("zodiac.taurus", locale: locale)
        case .gemini: appLocalized("zodiac.gemini", locale: locale)
        case .cancer: appLocalized("zodiac.cancer", locale: locale)
        case .leo: appLocalized("zodiac.leo", locale: locale)
        case .virgo: appLocalized("zodiac.virgo", locale: locale)
        case .libra: appLocalized("zodiac.libra", locale: locale)
        case .scorpio: appLocalized("zodiac.scorpio", locale: locale)
        case .sagittarius: appLocalized("zodiac.sagittarius", locale: locale)
        case .capricorn: appLocalized("zodiac.capricorn", locale: locale)
        case .aquarius: appLocalized("zodiac.aquarius", locale: locale)
        case .pisces: appLocalized("zodiac.pisces", locale: locale)
        }
    }
}
