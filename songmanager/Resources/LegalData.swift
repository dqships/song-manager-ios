import Foundation

enum LegalDocument: String, CaseIterable, Identifiable {
    case terms
    case privacy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .terms: return "Terms"
        case .privacy: return "Privacy"
        }
    }

    var body: String {
        switch self {
        case .terms:
            return LegalData.terms
        case .privacy:
            return LegalData.privacy
        }
    }
}

enum LegalData {
    static let terms: String = """
    Terms of Service — ReleaseKit

    1) Acceptance. By installing or using ReleaseKit, you agree to these terms. If you do not agree, do not use the app.

    2) Eligibility. Keep your device secure. You are responsible for actions taken in the app on your device.

    3) Your content and storage. Songs, collaborators, notes, splits, statuses, and registrations you add stay stored locally on your device. There is no cloud sync in this version. We do not see, collect, or host your catalog data. If you uninstall the app or wipe your device, local data is removed. Export important records before uninstalling.

    4) Purchases and subscriptions. Purchases run through the App Store and RevenueCat. Billing terms, pricing, renewals, and cancellations are handled by the App Store. Your subscription controls access to Pro features; if billing fails, Pro access may pause until restored. Manage or cancel in App Store settings.

    5) Acceptable use. Do not store unlawful or infringing content, attempt to bypass subscription checks, interfere with the app or providers, or reverse engineer, resell, or redistribute the app.

    6) No professional advice. Registration checklists are tools only. You are responsible for verifying accuracy and meeting each agency’s requirements.

    7) Disclaimers. The app is provided “as is” without warranties. We do not guarantee uninterrupted service, error-free content, or fitness for a particular purpose.

    8) Limitation of liability. To the maximum extent permitted by law, our liability is limited to the amounts you paid for the app or subscription (if any). Some jurisdictions do not allow certain limitations, so these may not fully apply to you.

    9) Termination. You may stop using the app at any time by uninstalling it and canceling subscriptions through the App Store. We may suspend or terminate access for violations of these terms or applicable law.

    10) Changes. We may update these terms and will post the date of the latest change. Continued use after updates means you accept the revised terms.

    11) Contact. For term questions, email legal@example.com.
    """

    static let privacy: String = """
    Privacy Policy — ReleaseKit

    Summary. ReleaseKit is offline-first. Your catalog (songs, collaborators, notes, splits, statuses, registrations) is stored on your device. We do not collect or view your catalog data. Purchases run through the App Store and RevenueCat, which process minimal identifiers for billing and entitlements.

    1) Data we do not collect. We do not collect your song content, collaborator details, registration notes, or other catalog entries. We do not run our own analytics in the iOS app.

    2) Data we handle.
    - Subscriptions: RevenueCat and the App Store process transactions and entitlements. We receive status needed to enable Pro features; we do not receive your payment details.
    - Music library access: Used only if you choose to import your own tracks; access remains local.
    - Siri: Apple processes Siri requests under your Siri and Apple privacy settings. ReleaseKit receives resolved request details and saves the requested catalog change locally. We do not send those details to a ReleaseKit backend.

    3) Storage and retention. Catalog data stays local until you delete entries or uninstall the app. Signing out does not automatically delete local data. Export any needed records before uninstalling or resetting your device.

    4) Sharing. We do not sell or share your catalog data. RevenueCat and the App Store receive purchase-related data to fulfill subscriptions.

    5) Security. Keep your device secure (passcode/biometrics). Because data is local, loss of device can mean loss of catalog unless you maintain your own device backups.

    6) Your choices. Manage subscriptions in App Store settings. Remove catalog entries directly in the app if you want them deleted before uninstalling.

    7) Children. The app is not directed to children under 13 (or the minimum age in your region). Do not use the app if you are under the applicable age.

    8) Changes. We may update this policy and will note the latest date in the app or on the website.

    9) Contact. For privacy questions or requests, email privacy@example.com.
    """
}
