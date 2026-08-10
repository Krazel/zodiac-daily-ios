import SwiftUI
import StoreKit

struct RootView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview
    @AppStorage("review-prompted-version") private var reviewPromptedVersion = ""
    @State private var selectedTab: Int

    init() {
        let visualState = AppModel.visualQAState
        let initialTab = visualState == .savedEmpty || visualState == .savedPopulated ? 1 : 0
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        Group {
            if AppModel.visualQAState == .savedDetail,
               let card = model.savedCards.first {
                NavigationStack {
                    SavedCardDetailView(card: card)
                }
            } else if model.selectedSign == nil {
                SignSelectionView(requiresSelection: true)
            } else {
                TabView(selection: $selectedTab) {
                    TodayView()
                        .tag(0)

                    SavedView {
                        selectedTab = 0
                    }
                        .tag(1)
                }
                .toolbar(.hidden, for: .tabBar)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    customTabBar
                }
            }
        }
        .task {
            await model.start()
        }
        .onChange(of: model.selectedSign) { _ in
            Task { await model.refreshDailyCard() }
        }
        .onChange(of: model.successfulSaveEvent) { _ in
            requestReviewAfterMeaningfulUseIfEligible()
        }
        .onChange(of: scenePhase) { phase in
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
        .onAppear {
            #if DEBUG
            if let visualState = AppModel.visualQAState {
                let markerURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("visual-qa-rendered-state.txt")
                try? Data(visualState.rawValue.utf8).write(
                    to: markerURL,
                    options: .atomic
                )
            }
            #endif
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "TODAY", systemImage: "sparkle", tab: 0)
            tabButton(title: "SAVED", systemImage: selectedTab == 1 ? "bookmark.fill" : "bookmark", tab: 1)
        }
        .frame(height: 53)
        .background {
            LinearGradient(
                colors: [ZodiacPalette.deepIndigo.opacity(0.97), ZodiacPalette.midnight.opacity(0.99)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.22))
                .frame(height: 0.7)
        }
    }

    private func tabButton(title: String, systemImage: String, tab: Int) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .light))
                    .frame(height: 22)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .tracking(2.0)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? ZodiacPalette.paleGold : ZodiacPalette.lavender.opacity(0.72))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(isSelected ? ZodiacPalette.gold : Color.clear)
                    .frame(width: 83, height: 2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title.capitalized)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func requestReviewAfterMeaningfulUseIfEligible() {
        guard model.savedCards.count >= 3 else { return }
        let currentVersion = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "unknown"
        guard reviewPromptedVersion != currentVersion else { return }

        reviewPromptedVersion = currentVersion
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled else { return }
            requestReview()
        }
    }
}
