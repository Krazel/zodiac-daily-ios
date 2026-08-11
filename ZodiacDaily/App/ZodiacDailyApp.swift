import SwiftUI

@main
struct ZodiacDailyApp: App {
    @StateObject private var model = AppModel()
    @StateObject private var supportStore = SupportStore()
    @AppStorage(AppLanguage.storageKey) private var appLanguageRawValue: String

    init() {
        let initialLanguage = AppLanguage.persistedOrPreferred()
        _appLanguageRawValue = AppStorage(
            wrappedValue: initialLanguage.rawValue,
            AppLanguage.storageKey
        )
    }

    private var appLanguage: AppLanguage {
        AppLanguage(rawValue: appLanguageRawValue) ?? .english
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .environmentObject(supportStore)
                .environment(\.locale, appLanguage.locale)
                .preferredColorScheme(.dark)
                .task {
                    await supportStore.start()
                }
                .onChange(of: appLanguageRawValue) { newValue in
                    Task {
                        await model.setAppLanguage(rawValue: newValue)
                    }
                }
        }
    }
}
