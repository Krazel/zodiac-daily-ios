import Foundation
import Combine
import ZodiacDailyCore

@MainActor
final class AppModel: ObservableObject {
    enum VisualQAState: String {
        case signSelection = "sign-selection"
        case today
        case todayBack = "today-back"
        case todayLong = "today-long"
        case savedEmpty = "saved-empty"
        case savedPopulated = "saved-populated"
        case savedDetail = "saved-detail"
        case settings
    }

    enum DailyState: Equatable {
        case idle
        case loading
        case loaded(DailyHoroscope)
        case failed(String)
    }

    @Published var selectedSign: ZodiacSign? {
        didSet {
            guard oldValue != selectedSign else { return }
            userDefaults.set(selectedSign?.rawValue, forKey: Self.selectedSignKey)
        }
    }
    @Published private(set) var dailyState: DailyState = .idle
    @Published private(set) var savedCards: [SavedCard] = []
    @Published private(set) var persistenceMessage: String?
    @Published private(set) var successfulSaveEvent: UInt = 0

    private static let selectedSignKey = "selected-zodiac-sign"

    static var visualQAState: VisualQAState? {
        #if DEBUG
        ProcessInfo.processInfo.environment["ZODIAC_VISUAL_QA_STATE"]
            .flatMap(VisualQAState.init(rawValue:))
        #else
        nil
        #endif
    }

    private let repository: (any HoroscopeRepository)?
    private let savedStore: any SavedCardStore
    private let userDefaults: UserDefaults
    private let now: @Sendable () -> Date
    private let initializationMessage: String?
    private var refreshGeneration: UInt64 = 0

    init(
        userDefaults: UserDefaults = .standard,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        let visualQAState = Self.visualQAState
        self.userDefaults = userDefaults
        if visualQAState != nil {
            let visualQADate = Date(timeIntervalSince1970: 1_786_233_600)
            self.now = { visualQADate }
        } else {
            self.now = now
        }
        if visualQAState == .signSelection {
            selectedSign = nil
        } else if visualQAState != nil {
            selectedSign = .pisces
        } else {
            selectedSign = userDefaults.string(forKey: Self.selectedSignKey)
                .flatMap(ZodiacSign.init(rawValue:))
        }

        let supportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        let archiveDirectory = supportDirectory
            .appendingPathComponent("ZodiacDaily", isDirectory: true)
        #if DEBUG
        if let visualQAState {
            let cards = Self.visualQACards(for: visualQAState)
            savedStore = InMemorySavedCardStore(cards: cards)
            savedCards = cards
        } else {
            savedStore = FileBackedSavedCardStore(
                fileURL: archiveDirectory.appendingPathComponent("saved-cards.json")
            )
        }
        #else
        savedStore = FileBackedSavedCardStore(
            fileURL: archiveDirectory.appendingPathComponent("saved-cards.json")
        )
        #endif

        do {
            let bundledRepository = try BundledHoroscopeRepository()
            let source: any HoroscopeRepository
            if let baseURL = AppConfiguration.apiBaseURL,
               let remoteRepository = try? RemoteHoroscopeRepository(baseURL: baseURL) {
                source = FallbackHoroscopeRepository(
                    primary: remoteRepository,
                    fallback: bundledRepository
                )
            } else {
                source = bundledRepository
            }
            repository = PinnedHoroscopeRepository(
                upstream: source,
                store: FileBackedSavedCardStore(
                    fileURL: archiveDirectory.appendingPathComponent("daily-editions.json"),
                    recoveryPolicy: .replaceCorruptArchive
                ),
                now: now
            )
            initializationMessage = nil
        } catch {
            repository = nil
            initializationMessage = error.localizedDescription
        }
    }

    #if DEBUG
    private static func visualQACards(for state: VisualQAState) -> [SavedCard] {
        guard state == .savedPopulated || state == .savedDetail else { return [] }

        let fixtures: [(ZodiacSign, String, String, String)] = [
            (
                .pisces,
                "2026-08-09",
                "Let the Tide Turn",
                "You do not need to force the next step. Listen for the rhythm beneath the noise, then move with it."
            ),
            (
                .scorpio,
                "2026-08-08",
                "Trust the Quiet Answer",
                "The answer arrives when the room grows still. Give your deepest knowing space to speak."
            ),
            (
                .sagittarius,
                "2026-08-06",
                "Choose the Wider Road",
                "A broader path is opening. Follow the direction that gives your spirit room to expand."
            )
        ]

        return fixtures.compactMap { fixture in
            let (sign, rawDay, headline, reading) = fixture
            guard let day = LocalDayKey(rawValue: rawDay) else { return nil }
            return SavedCard(
                horoscope: DailyHoroscope(
                    sign: sign,
                    day: day,
                    headline: headline,
                    reading: reading,
                    contentVersion: 1
                ),
                savedAt: day.startDate(in: TimeZone(secondsFromGMT: 0)!) ?? Date()
            )
        }
    }

    private static func visualQAPiscesCard(longCopy: Bool = false) -> DailyHoroscope {
        let regularReading = "You do not need to force the next step. Listen for the rhythm beneath the noise, then move with it."
        let longReading = "You can move gently without losing momentum. Notice which conversations leave you feeling clearer, then make room for one honest answer before the day becomes busy. A practical choice around work or money benefits from patience rather than pressure. In love, listen for what is meant beneath the words. Protect a quiet hour for rest, reflection, and the small ritual that returns you to yourself."
        return DailyHoroscope(
            sign: .pisces,
            day: LocalDayKey(rawValue: "2026-08-09")!,
            headline: "Let the Tide Turn",
            reading: longCopy ? longReading : regularReading,
            details: .provider(
                focus: "Intuition",
                keywords: ["Empathy", "Flow", "Imagination"],
                loveScore: 83,
                careerScore: 89,
                moneyScore: 85,
                healthScore: 78,
                luckyColor: "Silver",
                luckyNumber: 61,
                moonSign: "Capricorn",
                moonPhase: "Last Quarter",
                sign: .pisces
            ),
            contentVersion: 1
        )
    }
    #endif

    var isCurrentCardSaved: Bool {
        guard case .loaded(let horoscope) = dailyState else { return false }
        return savedCards.contains { $0.id == horoscope.archiveKey }
    }

    func start() async {
        await reloadSavedCards()
        await refreshDailyCard()
    }

    func select(_ sign: ZodiacSign) {
        selectedSign = sign
    }

    func refreshDailyCard() async {
        refreshGeneration &+= 1
        let generation = refreshGeneration

        #if DEBUG
        if Self.visualQAState == .today
            || Self.visualQAState == .todayBack
            || Self.visualQAState == .todayLong
            || Self.visualQAState == .settings {
            dailyState = .loaded(
                Self.visualQAPiscesCard(longCopy: Self.visualQAState == .todayLong)
            )
            return
        }
        #endif

        guard let sign = selectedSign else {
            dailyState = .idle
            return
        }
        guard let repository else {
            dailyState = .failed(initializationMessage ?? "The daily reading is unavailable.")
            return
        }

        dailyState = .loading
        let day = LocalDayKey(date: now(), timeZone: .current)
        do {
            let horoscope = try await repository.horoscope(for: sign, day: day)
            guard generation == refreshGeneration,
                  selectedSign == sign,
                  LocalDayKey(date: now(), timeZone: .current) == day else { return }
            let displayed = savedCards.first { $0.id == horoscope.archiveKey }?.horoscope
                ?? horoscope
            dailyState = .loaded(displayed)
        } catch {
            guard generation == refreshGeneration,
                  selectedSign == sign,
                  LocalDayKey(date: now(), timeZone: .current) == day else { return }
            dailyState = .failed(error.localizedDescription)
        }
    }

    func toggleCurrentCardSaved() async {
        guard case .loaded(let horoscope) = dailyState else { return }
        persistenceMessage = nil
        let isSaving = !isCurrentCardSaved

        do {
            if !isSaving {
                try await savedStore.remove(id: horoscope.archiveKey)
            } else {
                try await savedStore.save(SavedCard(horoscope: horoscope, savedAt: now()))
            }
            await reloadSavedCards()
            if isSaving, persistenceMessage == nil {
                successfulSaveEvent &+= 1
            }
        } catch {
            persistenceMessage = error.localizedDescription
        }
    }

    func removeSavedCard(id: SavedCard.ID) async {
        persistenceMessage = nil
        do {
            try await savedStore.remove(id: id)
            await reloadSavedCards()
        } catch {
            persistenceMessage = error.localizedDescription
        }
    }

    func reloadSavedCards() async {
        do {
            savedCards = try await savedStore.allCards()
            persistenceMessage = nil
        } catch {
            savedCards = []
            persistenceMessage = error.localizedDescription
        }
    }
}
