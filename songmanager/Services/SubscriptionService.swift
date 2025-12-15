import Foundation
import RevenueCat
import Combine

@MainActor
final class SubscriptionService: ObservableObject {
    @Published private(set) var hasProAccess: Bool
    @Published private(set) var isLifetimeAccess: Bool
    @Published private(set) var activeProductIdentifier: String?

    private let entitlementKeys: [String]
    private let shouldAutoRefresh: Bool

    init(initialStatus: Bool = false, entitlementKeys: [String] = ["pro", "releasekit_pro"], autoRefresh: Bool = true) {
        self.hasProAccess = initialStatus
        self.isLifetimeAccess = false
        self.entitlementKeys = entitlementKeys
        self.shouldAutoRefresh = autoRefresh

        if autoRefresh {
            Task { await refreshStatus() }
        }
    }

    func refreshStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let entitlement = entitlementKeys.compactMap { key in
                customerInfo.entitlements[key]
            }.first(where: { $0.isActive })

            hasProAccess = entitlement != nil
            activeProductIdentifier = entitlement?.productIdentifier
            if let entitlement {
                let isLifetimeByProductID = entitlement.productIdentifier.lowercased().contains("lifetime")
                let isNonExpiring = entitlement.expirationDate == nil
                isLifetimeAccess = isLifetimeByProductID || isNonExpiring
            } else {
                isLifetimeAccess = false
            }
        } catch {
            print("Failed to fetch entitlements: \(error)")
        }
    }
}

#if DEBUG
extension SubscriptionService {
    static func previewPro() -> SubscriptionService {
        SubscriptionService(initialStatus: true, autoRefresh: false)
    }
}
#endif
