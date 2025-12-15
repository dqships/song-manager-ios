import AppIntents

extension ReleaseKitAssistantIntent {
    func performSummarizeSong() async throws -> IntentDialog {
        guard let song else { throw $song.needsValueError("Which song should I summarize?") }
        let summary = await MainActor.run {
            AppStateViewModel.live().songs.first(where: { $0.id == song.id }).map(SiriSongSummaryFormatter.format)
        }
        guard let summary else { throw SiriDataError.songNotFound }
        return "\(summary) Anything else?"
    }
}
