import Foundation
import Combine
import StoreKit

@MainActor
final class SupportStore: ObservableObject {
    enum CatalogState: Equatable {
        case idle
        case loading
        case available
        case partial
        case unavailable
        case restricted
    }

    enum StatusMessage: Equatable {
        case purchasesUnavailable
        case optionUnavailable
        case verificationFailed
        case thankYou
        case pending
        case purchaseFailed
        case restored
        case noneFound
        case restoreFailed
        case configurationError
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var catalogState: CatalogState = .idle
    @Published private(set) var activeProductID: String?
    @Published private(set) var purchasingProductID: String?
    @Published private(set) var isRestoring = false
    @Published private(set) var statusMessage: StatusMessage?

    private var updatesTask: Task<Void, Never>?
    private var hasStarted = false

    var isSupporter: Bool { activeProductID != nil }
    var canMakePayments: Bool { AppStore.canMakePayments }

    init() {
        updatesTask = observeTransactionUpdates()
    }

    deinit {
        updatesTask?.cancel()
    }

    func start() async {
        guard !hasStarted else { return }
        hasStarted = true
        await refreshEntitlements()
        await loadProducts()
    }

    func retryCatalog() async {
        await loadProducts()
    }

    func purchase(_ product: Product) async {
        guard purchasingProductID == nil, !isRestoring else { return }
        guard canMakePayments else {
            catalogState = .restricted
            statusMessage = .purchasesUnavailable
            return
        }
        guard Self.isValidSupportProduct(product) else {
            statusMessage = .optionUnavailable
            return
        }

        purchasingProductID = product.id
        statusMessage = nil
        defer { purchasingProductID = nil }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification,
                      Self.productIDs.contains(transaction.productID)
                else {
                    statusMessage = .verificationFailed
                    return
                }
                activeProductID = transaction.productID
                statusMessage = .thankYou
                await transaction.finish()
                await refreshEntitlements()
            case .pending:
                statusMessage = .pending
            case .userCancelled:
                break
            @unknown default:
                statusMessage = .purchaseFailed
            }
        } catch {
            statusMessage = .purchaseFailed
        }
    }

    func restorePurchases() async {
        guard !isRestoring, purchasingProductID == nil else { return }
        guard canMakePayments else {
            statusMessage = .purchasesUnavailable
            return
        }
        isRestoring = true
        statusMessage = nil
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = isSupporter ? .restored : .noneFound
        } catch {
            statusMessage = .restoreFailed
        }
    }

    private func loadProducts() async {
        guard canMakePayments else {
            products = []
            catalogState = .restricted
            return
        }

        catalogState = .loading
        do {
            let loaded = try await Product.products(for: Self.productIDs)
                .filter(Self.isValidSupportProduct)
                .sorted { lhs, rhs in
                    (Self.productIDs.firstIndex(of: lhs.id) ?? .max)
                        < (Self.productIDs.firstIndex(of: rhs.id) ?? .max)
                }
            let subscriptionGroupIDs = Set(
                loaded.compactMap { $0.subscription?.subscriptionGroupID }
            )
            guard subscriptionGroupIDs.count <= 1 else {
                products = []
                catalogState = .unavailable
                statusMessage = .configurationError
                return
            }
            products = loaded
            if loaded.isEmpty {
                catalogState = .unavailable
            } else if loaded.count == Self.productIDs.count {
                catalogState = .available
            } else {
                catalogState = .partial
            }
        } catch {
            products = []
            catalogState = .unavailable
        }
    }

    private func refreshEntitlements() async {
        var entitledProductID: String?
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  Self.productIDs.contains(transaction.productID),
                  transaction.revocationDate == nil,
                  transaction.expirationDate.map({ $0 > Date() }) ?? true
            else {
                continue
            }
            entitledProductID = transaction.productID
            break
        }
        activeProductID = entitledProductID
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard !Task.isCancelled else { return }
                guard case .verified(let transaction) = result,
                      Self.productIDs.contains(transaction.productID)
                else {
                    continue
                }
                await self?.refreshEntitlements()
                await transaction.finish()
            }
        }
    }

    private static let productIDs = AppConfiguration.supporterProductIDs

    private static func isValidSupportProduct(_ product: Product) -> Bool {
        guard productIDs.contains(product.id),
              product.type == .autoRenewable,
              let subscription = product.subscription
        else {
            return false
        }
        return subscription.subscriptionPeriod.unit == .month
            && subscription.subscriptionPeriod.value == 1
    }
}
