import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if model.selectedSign == nil {
                SignSelectionView(requiresSelection: true)
            } else {
                TabView(selection: $selectedTab) {
                    TodayView()
                        .tabItem {
                            Label("Today", systemImage: "sparkles")
                        }
                        .tag(0)

                    SavedView {
                        selectedTab = 0
                    }
                        .tabItem {
                            Label("Saved", systemImage: "bookmark")
                        }
                        .tag(1)
                }
                .tint(ZodiacPalette.gold)
                .toolbarBackground(ZodiacPalette.midnight, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarColorScheme(.dark, for: .tabBar)
            }
        }
        .task {
            await model.start()
        }
        .onChange(of: model.selectedSign) { _, _ in
            Task { await model.refreshDailyCard() }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await model.refreshDailyCard() }
        }
        .task(id: model.selectedSign) {
            guard model.selectedSign != nil else { return }

            while !Task.isCancelled {
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = .current
                let now = Date()
                guard let nextMidnight = calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: calendar.startOfDay(for: now)
                ) else { return }

                let delay = max(1, nextMidnight.timeIntervalSince(now) + 1)
                do {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } catch {
                    return
                }

                guard !Task.isCancelled else { return }
                await model.refreshDailyCard()
            }
        }
    }
}
