import AppIntents

struct ChangeSongPhaseIntent: AppIntent {
    static let title: LocalizedStringResource = "Change a Song Phase"
    static let description = IntentDescription("Change where a song is in the writing and release process.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Song", requestValueDialog: "Which song should I move?") var song: SongAppEntity
    @Parameter(title: "Phase", requestValueDialog: "What phase should I move it to?") var phase: SiriSongPhase

    static var parameterSummary: some ParameterSummary {
        Summary("Move \(\.$song) to \(\.$phase)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await MainActor.run { try AppStateViewModel.live().updateSongPhaseForSiri(id: song.id, phase: phase.songPhase) }
        return .result(dialog: "Moved \(song.title) to \(phase.rawValue). Anything else?")
    }
}
