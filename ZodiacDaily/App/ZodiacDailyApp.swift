import SwiftUI

@main
struct ZodiacDailyApp: App {
    @StateObject private var model = AppModel()
    @StateObject private var supportStore = SupportStore()
    @AppStorage(AppLanguage.storageKey) private var appLanguageRawValue =
        AppLanguage.persistedOrPreferred().rawValue

    private var appLanguage: AppLanguage {
        // AppModel is the source of truth for both interface copy and the
        // provider edition. Deriving the locale from its published language
        // prevents the two from briefly (or, in a presented sheet, visibly)
        // disagreeing after a Settings change.
        model.contentLanguage == .spanish ? .spanish : .english
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .environmentObject(supportStore)
                .environment(\.locale, appLanguage.locale)
                .preferredColorScheme(.dark)
                .task {
                    if AppConfiguration.supporterPurchasesEnabled {
                        await supportStore.start()
                    }
                }
                .onChange(of: appLanguageRawValue) { newValue in
                    Task {
                        await model.setAppLanguage(rawValue: newValue)
                    }
                }
        }
    }
}
