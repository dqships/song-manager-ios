import AppIntents

struct AttachCollaboratorIntent: AppIntent {
    static let title: LocalizedStringResource = "Add a Saved Collaborator to a Song"
    static let description = IntentDescription("Add a collaborator already saved in ReleaseKit to an existing song.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Collaborator", requestValueDialog: "Which saved collaborator?") var collaborator: CollaboratorAppEntity
    @Parameter(title: "Song", requestValueDialog: "Which song should I add them to?") var song: SongAppEntity
    @Parameter(title: "Role") var contribution: SiriContribution?
    @Parameter(title: "Split type") var splitScope: SiriSplitScope?
    @Parameter(title: "Percentage") var percentage: Double?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$collaborator) to \(\.$song)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        if splitScope != nil, percentage == nil {
            throw $percentage.needsValueError("What percentage should I save?")
        }
        if percentage != nil, splitScope == nil {
            throw $splitScope.needsValueError("Is that for the master, publishing, or both?")
        }
        if let percentage, (!percentage.isFinite || !(0...100).contains(percentage)) {
            throw SiriDataError.invalidPercentage
        }
        let confirmedPreview: SiriSplitPreview?
        if contribution != nil || percentage != nil {
            guard await SiriSubscriptionAccess.hasProAccess() else { throw SiriDataError.proAccessRequired }
            let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
            let roleText = contribution.map { " as \($0.dialogName)" } ?? ""
            if let percentage, let splitScope {
                let preview = try await MainActor.run {
                    try AppStateViewModel.live().previewAttachCollaboratorForSiri(
                        collaboratorID: collaborator.id,
                        songID: song.id,
                        splitScope: splitScope,
                        percentage: percentage
                    )
                }
                let confirmation = SiriAttachAllocationConfirmationFormatter.format(
                    collaboratorName: name,
                    songTitle: song.title,
                    roleText: contribution?.dialogName ?? "",
                    preview: preview
                )
                try await requestConfirmation(
                    result: .result(dialog: "\(confirmation)")
                )
                confirmedPreview = preview
            } else {
                try await requestConfirmation(result: .result(dialog: "Add \(name) to \(song.title)\(roleText)?"))
                confirmedPreview = nil
            }
        } else {
            confirmedPreview = nil
        }
        try await MainActor.run {
            try AppStateViewModel.live().attachCollaboratorForSiri(
                collaboratorID: collaborator.id,
                songID: song.id,
                contribution: contribution?.contribution,
                splitScope: splitScope,
                percentage: percentage,
                confirmedPreview: confirmedPreview
            )
        }
        let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
        return .result(dialog: "Added \(name) to \(song.title). Anything else?")
    }
}
