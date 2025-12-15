import AppIntents

struct ControlSongPlaybackIntent: AppIntent {
    static let title: LocalizedStringResource = "Control Song Playback"
    static let description = IntentDescription("Play, pause, or resume an imported song.")

    @Parameter(title: "Song", requestValueDialog: "Which imported song?") var song: SongAppEntity
    @Parameter(title: "Action", requestValueDialog: "Should I play, pause, or resume it?") var action: SiriPlaybackAction

    static var parameterSummary: some ParameterSummary { Summary("\(\.$action) \(\.$song)") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let persistentID = await MainActor.run(body: { AppStateViewModel.live().songs.first(where: { $0.id == song.id })?.mediaLibraryPersistentID }) else {
            throw SiriDataError.songNotFound
        }
        let error = await MainActor.run { () -> String? in
            switch action {
            case .play: return MusicLibraryPlaybackService.shared.play(persistentID: persistentID)
            case .pause: MusicLibraryPlaybackService.shared.pause(); return nil
            case .resume: MusicLibraryPlaybackService.shared.resume(); return nil
            }
        }
        if let error { throw SiriDataError.playbackUnavailable(error) }
        return .result(dialog: "Updated playback for \(song.title). Anything else?")
    }
}
