import AppIntents

struct CreateSongFromDescriptionIntent: AppIntent {
    static let title: LocalizedStringResource = "Describe a Song to Add"
    static let description = IntentDescription("Create a song from a bounded English description after confirming the details ReleaseKit understood.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Song description", requestValueDialog: "Describe the song, collaborator, role, and any split.") var request: String
    @Parameter(title: "Percentage applies to") var splitScope: SiriSplitScope?

    static var parameterSummary: some ParameterSummary { Summary("Describe \(\.$request)") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let parsed = try SiriSongDescriptionParser.parse(request)
        var masterSplit = parsed.splits.master
        var publishingSplit = parsed.splits.publishing
        if let ambiguous = parsed.splits.ambiguous {
            guard let splitScope else {
                let percentage = SiriPercentageFormatter.string(from: ambiguous)
                throw $splitScope.needsValueError("Does \(percentage)% apply to the master, publishing, or both?")
            }
            switch splitScope {
            case .master: masterSplit = ambiguous
            case .publishing: publishingSplit = ambiguous
            case .both:
                masterSplit = ambiguous
                publishingSplit = ambiguous
            }
        }

        let hasProAccess = await SiriSubscriptionAccess.hasProAccess()
        let compoundRequest = SiriCreateSongWithCreditsRequest(
            title: parsed.title,
            phase: parsed.phase,
            releaseDate: nil,
            existingCollaboratorID: nil,
            collaboratorArtistName: parsed.collaborator?.artistName,
            collaboratorSongwriterName: parsed.collaborator?.songwriterName,
            collaboratorPRO: nil,
            collaboratorIPI: nil,
            contributions: parsed.contribution.map { [$0] } ?? [],
            masterSplit: masterSplit,
            publishingSplit: publishingSplit
        )
        let plan = try await MainActor.run {
            try AppStateViewModel.live().planSongWithCreditsForSiri(request: compoundRequest, hasProAccess: hasProAccess)
        }
        let confirmation: IntentDialog = "\(plan.confirmation)"
        try await requestConfirmation(result: .result(dialog: confirmation))
        let result = try await MainActor.run {
            try AppStateViewModel.live().createSongWithCreditsForSiri(
                request: compoundRequest,
                hasProAccess: hasProAccess,
                confirmedPlan: plan
            )
        }
        return .result(dialog: "Added \(result.title) to your catalog. Anything else?")
    }
}
