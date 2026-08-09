import SwiftUI

@main
struct ZodiacDailyApp: App {
    @StateObject private var model = AppModel()
    @StateObject private var supportStore = SupportStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .environmentObject(supportStore)
                .preferredColorScheme(.dark)
                .task {
                    await supportStore.start()
                }
        }
    }
}
