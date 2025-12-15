import AppIntents

extension ReleaseKitAssistantIntent {
    func performAttachSavedCollaborator() async throws -> IntentDialog {
        guard let song else { throw $song.needsValueError("Which song should I add them to?") }
        guard let collaborator else { throw $collaborator.needsValueError("Which saved collaborator?") }
        let resolvedMaster = masterSplit ?? 0
        let resolvedPublishing = publishingSplit ?? 0
        let roles = Set([contribution?.contribution, additionalContribution?.contribution].compactMap { $0 })
        if !roles.isEmpty || resolvedMaster != 0 || resolvedPublishing != 0 {
            guard await SiriSubscriptionAccess.hasProAccess() else { throw SiriDataError.proAccessRequired }
        }
        let preview = try await MainActor.run {
            try AppStateViewModel.live().previewAttachCollaboratorAllocationForSiri(
                collaboratorID: collaborator.id,
                songID: song.id,
                master: resolvedMaster,
                publishing: resolvedPublishing
            )
        }
        let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
        let roleText = await MainActor.run { roles.map(\.displayName).sorted().joined(separator: ", ") }
        let confirmation = SiriAttachAllocationConfirmationFormatter.format(
            collaboratorName: name,
            songTitle: song.title,
            roleText: roleText,
            preview: preview
        )
        try await requestConfirmation(
            result: .result(dialog: "\(confirmation)")
        )
        try await MainActor.run {
            try AppStateViewModel.live().attachCollaboratorAllocationForSiri(
                collaboratorID: collaborator.id,
                songID: song.id,
                contributions: roles,
                master: resolvedMaster,
                publishing: resolvedPublishing,
                confirmedPreview: preview
            )
        }
        return "Added \(name) to \(song.title). Anything else?"
    }
}
