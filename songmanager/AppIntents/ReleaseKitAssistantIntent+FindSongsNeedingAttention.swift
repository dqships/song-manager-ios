import AppIntents

extension ReleaseKitAssistantIntent {
    func performFindSongsNeedingAttention() async throws -> IntentDialog {
        guard let attentionFilter else {
            throw $attentionFilter.needsValueError("Should I check registration, release dates, identifiers, splits, or a production phase?")
        }
        if attentionFilter == .phase, phase == nil {
            throw $phase.needsValueError("Which production phase?")
        }
        let summary = await MainActor.run {
            SiriAttentionFormatter.format(
                songs: AppStateViewModel.live().songs,
                filter: attentionFilter,
                phase: phase?.songPhase
            )
        }
        return "\(summary) Anything else?"
    }
}
