import AppIntents

enum SiriShortcutRegistration {
    static func refresh() {
        ReleaseKitAppShortcuts.updateAppShortcutParameters()
    }
}
