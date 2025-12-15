import AppIntents

struct UpdateSongSplitsIntent: AppIntent {
    static let title: LocalizedStringResource = "Update Song Splits"
    static let description = IntentDescription("Change master or publishing splits for a collaborator already on a song.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Song", requestValueDialog: "Which song?") var song: SongAppEntity
    @Parameter(title: "Collaborator", requestValueDialog: "Which collaborator?") var collaborator: CollaboratorAppEntity
    @Parameter(title: "Different master and publishing percentages", requestValueDialog: "Do master and publishing need different percentages?") var usesDifferentPercentages: Bool
    @Parameter(title: "Split type", requestValueDialog: "Is this for the master, publishing, or both?") var scope: SiriSplitScope?
    @Parameter(title: "Percentage", requestValueDialog: "What percentage should I save?") var percentage: Double?
    @Parameter(title: "Master percentage", requestValueDialog: "What master percentage should I save?") var masterPercentage: Double?
    @Parameter(title: "Publishing percentage", requestValueDialog: "What publishing percentage should I save?") var publishingPercentage: Double?

    static var parameterSummary: some ParameterSummary {
        Summary("Update splits for \(\.$collaborator) on \(\.$song)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard await SiriSubscriptionAccess.hasProAccess() else { throw SiriDataError.proAccessRequired }
        let owner = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
        var masterSplit = masterPercentage
        var publishingSplit = publishingPercentage
        if usesDifferentPercentages {
            if masterSplit == nil { throw $masterPercentage.needsValueError("What master percentage should I save?") }
            if publishingSplit == nil { throw $publishingPercentage.needsValueError("What publishing percentage should I save?") }
        } else {
            guard let scope else { throw $scope.needsValueError("Is this for the master, publishing, or both?") }
            guard let percentage else { throw $percentage.needsValueError("What percentage should I save?") }
            masterSplit = scope == .master || scope == .both ? percentage : nil
            publishingSplit = scope == .publishing || scope == .both ? percentage : nil
        }
        if let masterSplit, (!masterSplit.isFinite || !(0 ... 100).contains(masterSplit)) { throw SiriDataError.invalidSplit }
        if let publishingSplit, (!publishingSplit.isFinite || !(0 ... 100).contains(publishingSplit)) { throw SiriDataError.invalidSplit }
        let resolvedMasterSplit = masterSplit
        let resolvedPublishingSplit = publishingSplit
        let preview = try await MainActor.run {
            try AppStateViewModel.live().previewSongSplitsForSiri(
                songID: song.id,
                collaboratorID: collaborator.id,
                master: resolvedMasterSplit,
                publishing: resolvedPublishingSplit
            )
        }
        let collaboratorMaster = SiriPercentageFormatter.string(from: preview.collaboratorMaster)
        let collaboratorPublishing = SiriPercentageFormatter.string(from: preview.collaboratorPublishing)
        let primaryMaster = SiriPercentageFormatter.string(from: preview.primaryMaster)
        let primaryPublishing = SiriPercentageFormatter.string(from: preview.primaryPublishing)
        try await requestConfirmation(
            result: .result(
                dialog: "On \(song.title), set \(owner) to \(collaboratorMaster) percent master and \(collaboratorPublishing) percent publishing. Your remaining shares will be \(primaryMaster) percent master and \(primaryPublishing) percent publishing. Save this change?"
            )
        )
        try await MainActor.run {
            try AppStateViewModel.live().updateSongSplitsForSiri(
                songID: song.id,
                collaboratorID: collaborator.id,
                master: resolvedMasterSplit,
                publishing: resolvedPublishingSplit,
                confirmedPreview: preview
            )
        }
        return .result(dialog: "Updated the splits for \(owner) on \(song.title). Anything else?")
    }
}
