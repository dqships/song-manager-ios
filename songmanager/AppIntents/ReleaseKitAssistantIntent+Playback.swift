import AppIntents

extension ReleaseKitAssistantIntent {
    func performPlayImportedSong() async throws -> IntentDialog {
        guard let song else { throw $song.needsValueError("Which imported song should I play?") }
        let persistentID = await MainActor.run {
            AppStateViewModel.live().songs.first(where: { $0.id == song.id })?.mediaLibraryPersistentID
        }
        guard let persistentID else {
            throw SiriDataError.playbackUnavailable("That song is not linked to your Music library.")
        }
        if let message = await MainActor.run(body: { MusicLibraryPlaybackService.shared.play(persistentID: persistentID) }) {
            throw SiriDataError.playbackUnavailable(message)
        }
        return "Playing \(song.title). Anything else?"
    }

    func performPausePlayback() async -> IntentDialog {
        await MainActor.run { MusicLibraryPlaybackService.shared.pause() }
        return "Paused playback. Anything else?"
    }

    func performResumePlayback() async -> IntentDialog {
        await MainActor.run { MusicLibraryPlaybackService.shared.resume() }
        return "Resumed playback. Anything else?"
    }
}
