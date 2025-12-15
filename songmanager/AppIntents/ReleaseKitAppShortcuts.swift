import AppIntents

struct ReleaseKitAppShortcuts: AppShortcutsProvider {
    static let shortcutTileColor: ShortcutTileColor = .orange
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: AddSongIntent(), phrases: ["Add a song in \(.applicationName)", "Create a song in \(.applicationName)"], shortTitle: "Add song", systemImageName: "music.note")
        AppShortcut(intent: AddCollaboratorIntent(), phrases: ["Add a collaborator in \(.applicationName)", "Save a collaborator in \(.applicationName)"], shortTitle: "Add collaborator", systemImageName: "person.badge.plus")
        AppShortcut(intent: ChangeSongPhaseIntent(), phrases: ["Change a song phase in \(.applicationName)"], shortTitle: "Change phase", systemImageName: "arrow.triangle.2.circlepath")
        AppShortcut(intent: UpdateSongSplitsIntent(), phrases: ["Update song splits in \(.applicationName)"], shortTitle: "Update splits", systemImageName: "percent")
        AppShortcut(intent: CompleteRegistrationChecklistIntent(), phrases: ["Review a registration checklist in \(.applicationName)", "Complete a registration checklist in \(.applicationName)"], shortTitle: "Review checklist", systemImageName: "checklist")
        AppShortcut(intent: UpdateSongMetadataIntent(), phrases: ["Update song details in \(.applicationName)"], shortTitle: "Update song", systemImageName: "music.note.list")
        AppShortcut(intent: UpdateCollaboratorMetadataIntent(), phrases: ["Update a collaborator in \(.applicationName)"], shortTitle: "Update collaborator", systemImageName: "person.crop.circle.badge.checkmark")
        AppShortcut(intent: UpdateArtistProfileIntent(), phrases: ["Update artist profile in \(.applicationName)"], shortTitle: "Update profile", systemImageName: "person.crop.circle")
        AppShortcut(
            intent: ReleaseKitAssistantIntent(),
            phrases: ["\(\.$workflow) in \(.applicationName)", "Ask \(.applicationName) to \(\.$workflow)"],
            shortTitle: "Use Siri",
            systemImageName: "waveform"
        )
        AppShortcut(
            intent: ProtectedCatalogChangeIntent(),
            phrases: ["\(\.$action) in \(.applicationName)", "Ask \(.applicationName) to \(\.$action)"],
            shortTitle: "Delete or clear",
            systemImageName: "lock.shield"
        )
    }
}
