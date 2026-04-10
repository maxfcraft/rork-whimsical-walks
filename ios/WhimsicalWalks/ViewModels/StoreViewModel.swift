import Foundation
import Observation
import RevenueCat

@Observable
@MainActor
class StoreViewModel {
    var offerings: Offerings?
    var isPremium: Bool = false
    var isLoading: Bool = false
    var isPurchasing: Bool = false
    var error: String?
    var loadFailed: Bool = false
    private(set) var retryCount: Int = 0
    private let maxRetries: Int = 4
    private var isConfigured: Bool = false

    init() {}

    func start() {
        guard Purchases.isConfigured else {
            loadFailed = true
            error = "Subscription service not available."
            return
        }
        isConfigured = true
        Task { await listenForUpdates() }
        Task { await fetchOfferings() }
    }

    private func listenForUpdates() async {
        guard isConfigured else { return }
        for await info in Purchases.shared.customerInfoStream {
            self.isPremium = info.entitlements["premium"]?.isActive == true
        }
    }

    func fetchOfferings() async {
        guard isConfigured else {
            loadFailed = true
            error = "Subscription service not available."
            return
        }
        isLoading = true
        loadFailed = false
        error = nil
        retryCount = 0

        while retryCount <= maxRetries {
            do {
                let result = try await Purchases.shared.offerings()
                offerings = result
                if result.current != nil {
                    isLoading = false
                    return
                }
            } catch {
                self.error = error.localizedDescription
            }

            retryCount += 1
            if retryCount <= maxRetries {
                let delay = Double(min(retryCount * 2, 8))
                try? await Task.sleep(for: .seconds(delay))
            }
        }

        loadFailed = true
        if offerings?.current == nil {
            error = "No subscription plans available right now."
        }
        isLoading = false
    }

    func purchase(package: Package) async -> Bool {
        guard isConfigured else { return false }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                isPremium = result.customerInfo.entitlements["premium"]?.isActive == true
                return isPremium
            }
        } catch ErrorCode.purchaseCancelledError {
        } catch ErrorCode.paymentPendingError {
        } catch {
            self.error = error.localizedDescription
        }
        return false
    }

    func restore() async {
        guard isConfigured else { return }
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            self.error = error.localizedDescription
        }
    }

    func checkStatus() async {
        guard isConfigured else { return }
        do {
            let info = try await Purchases.shared.customerInfo()
            isPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            self.error = error.localizedDescription
        }
    }
}
