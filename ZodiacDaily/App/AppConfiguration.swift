import Foundation

enum AppConfiguration {
    private static let apiBaseURLKey = "ZodiacDailyAPIBaseURL"
    private static let appStoreIDKey = "ZodiacDailyAppStoreID"

    static let supporterProductIDs = [
        "com.krazel.zodiacdaily.support.monthly",
        "com.krazel.zodiacdaily.support.kind",
        "com.krazel.zodiacdaily.support.generous"
    ]

    static let privacyURL = URL(string: "https://krazel.github.io/zodiac-daily/privacy/")!
    static let supportURL = URL(string: "https://krazel.github.io/zodiac-daily/support/")!
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    /// A public endpoint address is configuration, not a secret. FreeAstroAPI
    /// credentials must never be placed in this value or anywhere in the app.
    static var apiBaseURL: URL? {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: apiBaseURLKey) as? String,
              !rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = URL(string: rawValue)
        else {
            return nil
        }
        return url
    }

    /// The numeric App Store ID does not exist until the App Store Connect
    /// record is created. The persistent review link remains unavailable until
    /// this non-secret build setting is configured.
    static var writeReviewURL: URL? {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: appStoreIDKey) as? String else {
            return nil
        }
        let appStoreID = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appStoreID.isEmpty,
              appStoreID.allSatisfy(\.isNumber)
        else {
            return nil
        }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")
    }
}
