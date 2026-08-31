import Foundation

enum AppConfiguration {
    private static let apiBaseURLKey = "ZodiacDailyAPIBaseURL"
    private static let appStoreIDKey = "ZodiacDailyAppStoreID"
    private static let productionAPIBaseURL = URL(
        string: "https://zodiac-daily-content.krazel-zodiac-daily.workers.dev"
    )!
    private static let productionAppStoreID = "6800136195"

    /// Paid support stays dormant for the first public release. The StoreKit
    /// implementation remains available for a later version after its products
    /// and review proposition are explicitly approved in App Store Connect.
    static let supporterPurchasesEnabled = false

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
    static var apiBaseURL: URL {
        if let rawValue = Bundle.main.object(forInfoDictionaryKey: apiBaseURLKey) as? String {
            let configuredValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if let url = URL(string: configuredValue),
               url.scheme?.lowercased() == "https",
               url.host?.isEmpty == false,
               url.user == nil,
               url.password == nil,
               url.query == nil,
               url.fragment == nil {
                return url
            }
        }

        // This public address is not a provider credential. Compiling a safe
        // default prevents a missing generated Info.plist key from silently
        // disabling the real daily edition again.
        return productionAPIBaseURL
    }

    /// The numeric App Store ID is supplied by the non-secret Xcode build
    /// setting registered with the App Store Connect record.
    static var writeReviewURL: URL? {
        let appStoreID = (Bundle.main.object(forInfoDictionaryKey: appStoreIDKey) as? String)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .flatMap { $0.isEmpty ? nil : $0 }
            ?? productionAppStoreID
        guard !appStoreID.isEmpty,
              appStoreID.allSatisfy(\.isNumber)
        else {
            return nil
        }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")
    }
}
