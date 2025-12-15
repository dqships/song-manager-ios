import Foundation
import RevenueCat

@MainActor
enum SiriSubscriptionAccess {
    static func hasProAccess() async -> Bool {
        let entitlementKeys = ["pro", "releasekit_pro"]
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements.active.keys.contains(where: { entitlementKeys.contains($0) })
        } catch {
            return Purchases.shared.cachedCustomerInfo?.entitlements.active.keys.contains(where: { entitlementKeys.contains($0) }) ?? false
        }
    }
}
