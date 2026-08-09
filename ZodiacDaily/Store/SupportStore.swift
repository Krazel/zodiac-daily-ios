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

    @Published private(set) var products: [Product] = []
    @Published private(set) var catalogState: CatalogState = .idle
    @Published private(set) var activeProductID: String?
    @Published private(set) var purchasingProductID: String?
    @Published private(set) var isRestoring = false
    @Published private(set) var statusMessage: String?

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
            statusMessage = "Purchases are not available on this device."
            return
        }
        guard Self.isValidSupportProduct(product) else {
            statusMessage = "This support option is temporarily unavailable."
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
                    statusMessage = "The purchase could not be verified. You were not marked as a supporter."
                    return
                }
                activeProductID = transaction.productID
                statusMessage = "Thank you for supporting Zodiac Daily."
                await transaction.finish()
                await refreshEntitlements()
            case .pending:
                statusMessage = "The purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                statusMessage = "The purchase could not be completed. Please try again."
            }
        } catch {
            statusMessage = "The purchase could not be completed. Please try again."
        }
    }

    func restorePurchases() async {
        guard !isRestoring, purchasingProductID == nil else { return }
        guard canMakePayments else {
            statusMessage = "Purchases are not available on this device."
            return
        }
        isRestoring = true
        statusMessage = nil
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = isSupporter
                ? "Your supporter status has been restored. Thank you."
                : "No active supporter subscription was found."
        } catch {
            statusMessage = "Purchases could not be restored. Please try again."
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
                statusMessage = "Support options are not configured correctly. No charge can be made."
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
