import Foundation

enum AppConfiguration {
    private static let apiBaseURLKey = "ZodiacDailyAPIBaseURL"

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
}
