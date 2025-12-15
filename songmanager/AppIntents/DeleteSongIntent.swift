import AppIntents

struct DeleteSongIntent: AppIntent {
    static let title: LocalizedStringResource = "Delete a Song"
    static let description = IntentDescription("Permanently delete one song from ReleaseKit.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresLocalDeviceAuthentication }

    @Parameter(title: "Song", requestValueDialog: "Which song should I delete?") var song: SongAppEntity

    static var parameterSummary: some ParameterSummary { Summary("Delete \(\.$song)") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await requestConfirmation(result: .result(dialog: "Delete \(song.title)? This cannot be undone."))
        try await MainActor.run { try AppStateViewModel.live().deleteSongForSiri(id: song.id) }
        return .result(dialog: "Deleted \(song.title). Anything else?")
    }
}
