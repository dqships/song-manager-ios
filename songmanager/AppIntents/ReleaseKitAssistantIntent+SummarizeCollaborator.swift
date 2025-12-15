import AppIntents

extension ReleaseKitAssistantIntent {
    func performSummarizeCollaborator() async throws -> IntentDialog {
        guard let collaborator else { throw $collaborator.needsValueError("Which collaborator should I summarize?") }
        let summary = await MainActor.run { () -> String? in
            let catalog = AppStateViewModel.live()
            guard let savedCollaborator = catalog.collaborators.first(where: { $0.id == collaborator.id }) else { return nil }
            return SiriCollaboratorSummaryFormatter.format(savedCollaborator, songs: catalog.songs)
        }
        guard let summary else { throw SiriDataError.collaboratorNotFound }
        return "\(summary) Anything else?"
    }
}
