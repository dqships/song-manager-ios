import AppIntents

extension ReleaseKitAssistantIntent {
    func performCheckReleaseReadiness() async throws -> IntentDialog {
        guard let song else { throw $song.needsValueError("Which song should I check?") }
        let summary = await MainActor.run {
            AppStateViewModel.live().songs.first(where: { $0.id == song.id }).map(SiriReadinessFormatter.format)
        }
        guard let summary else { throw SiriDataError.songNotFound }
        return "\(summary) Anything else?"
    }
}
