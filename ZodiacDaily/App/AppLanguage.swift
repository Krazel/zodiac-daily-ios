import Foundation
import SwiftUI
import ZodiacDailyCore

/// The two interface languages shipped by Zodiac Daily.
///
/// The raw value is also the persisted preference and the locale identifier
/// used by SwiftUI. Keeping those values stable makes the preference safe to
/// carry across app updates.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    static let storageKey = "app-language"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var horoscopeLanguage: HoroscopeLanguage {
        switch self {
        case .english:
            .english
        case .spanish:
            .spanish
        }
    }

    /// A key rather than a pre-resolved String so SwiftUI reevaluates it with
    /// the app's injected locale as soon as the user changes language.
    var displayName: LocalizedStringKey {
        switch self {
        case .english:
            "language.english"
        case .spanish:
            "language.spanish"
        }
    }

    /// Returns an existing valid choice, or detects and persists the initial
    /// language once. Spanish devices begin in Spanish; every other locale
    /// uses the English interface.
    static func persistedOrPreferred(
        userDefaults: UserDefaults = .standard,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> AppLanguage {
        if let storedValue = userDefaults.string(forKey: storageKey),
           let storedLanguage = AppLanguage(rawValue: storedValue) {
            return storedLanguage
        }

        let prefersSpanish = preferredLanguages.contains { identifier in
            let normalized = identifier
                .replacingOccurrences(of: "_", with: "-")
                .lowercased()
            return normalized == "es" || normalized.hasPrefix("es-")
        }
        let language: AppLanguage = prefersSpanish ? .spanish : .english
        userDefaults.set(language.rawValue, forKey: storageKey)
        return language
    }
}

/// Resolves a catalog key from the language selected inside the app rather
/// than from the iPhone's system language. `String(localized:locale:)` uses
/// its locale for formatting but still chooses the bundle localization from
/// the system preferences, which made non-`Text` labels remain in English.
func appLocalized(_ key: String, locale: Locale) -> String {
    let normalizedIdentifier = locale.identifier
        .replacingOccurrences(of: "_", with: "-")
        .lowercased()
    let language = normalizedIdentifier == "es" || normalizedIdentifier.hasPrefix("es-")
        ? "es"
        : "en"

    guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
          let localizedBundle = Bundle(path: path) else {
        return Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }
    return localizedBundle.localizedString(forKey: key, value: key, table: nil)
}
