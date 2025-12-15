import AppIntents

extension ReleaseKitAssistantIntent {
    func performReviewCatalog() async -> IntentDialog {
        let summary = await MainActor.run {
            SiriCatalogSummaryFormatter.format(songs: AppStateViewModel.live().songs)
        }
        return "\(summary) Anything else?"
    }
}
