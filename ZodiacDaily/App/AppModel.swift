import Foundation
import Combine
import ZodiacDailyCore

@MainActor
final class AppModel: ObservableObject {
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

    private static let selectedSignKey = "selected-zodiac-sign"
    private let repository: (any HoroscopeRepository)?
    private let savedStore: any SavedCardStore
    private let userDefaults: UserDefaults
    private let now: @Sendable () -> Date
    private let initializationMessage: String?

    init(
        userDefaults: UserDefaults = .standard,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.userDefaults = userDefaults
        self.now = now
        selectedSign = userDefaults.string(forKey: Self.selectedSignKey)
            .flatMap(ZodiacSign.init(rawValue:))

        do {
            repository = try BundledHoroscopeRepository()
            initializationMessage = nil
        } catch {
            repository = nil
            initializationMessage = error.localizedDescription
        }

        let supportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        let archiveURL = supportDirectory
            .appendingPathComponent("ZodiacDaily", isDirectory: true)
            .appendingPathComponent("saved-cards.json")
        savedStore = FileBackedSavedCardStore(fileURL: archiveURL)
    }

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
        guard let sign = selectedSign else {
            dailyState = .idle
            return
        }
        guard let repository else {
            dailyState = .failed(initializationMessage ?? "The daily reading is unavailable.")
            return
        }

        dailyState = .loading
        do {
            let day = LocalDayKey(date: now(), timeZone: .current)
            let horoscope = try await repository.horoscope(for: sign, day: day)
            guard selectedSign == sign else { return }
            dailyState = .loaded(horoscope)
        } catch {
            guard selectedSign == sign else { return }
            dailyState = .failed(error.localizedDescription)
        }
    }

    func toggleCurrentCardSaved() async {
        guard case .loaded(let horoscope) = dailyState else { return }
        persistenceMessage = nil

        do {
            if isCurrentCardSaved {
                try await savedStore.remove(id: horoscope.archiveKey)
            } else {
                try await savedStore.save(SavedCard(horoscope: horoscope, savedAt: now()))
            }
            await reloadSavedCards()
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
