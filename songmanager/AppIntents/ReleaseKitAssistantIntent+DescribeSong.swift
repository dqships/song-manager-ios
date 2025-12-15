import AppIntents

extension ReleaseKitAssistantIntent {
    func performDescribeSong() async throws -> IntentDialog {
        guard let request = SiriOptionalTextNormalizer.normalize(request) else {
            throw $request.needsValueError("Describe the song, collaborator, role, and any split.")
        }
        let parsed = try SiriSongDescriptionParser.parse(request)
        var resolvedMaster = parsed.splits.master
        var resolvedPublishing = parsed.splits.publishing
        if let ambiguous = parsed.splits.ambiguous {
            guard let splitScope else {
                let percentage = SiriPercentageFormatter.string(from: ambiguous)
                throw $splitScope.needsValueError("Does \(percentage) percent apply to the master, publishing, or both?")
            }
            switch splitScope {
            case .master: resolvedMaster = ambiguous
            case .publishing: resolvedPublishing = ambiguous
            case .both:
                resolvedMaster = ambiguous
                resolvedPublishing = ambiguous
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
            masterSplit: resolvedMaster,
            publishingSplit: resolvedPublishing
        )
        let plan = try await MainActor.run {
            try AppStateViewModel.live().planSongWithCreditsForSiri(request: compoundRequest, hasProAccess: hasProAccess)
        }
        try await requestConfirmation(result: .result(dialog: "\(plan.confirmation)"))
        let result = try await MainActor.run {
            try AppStateViewModel.live().createSongWithCreditsForSiri(
                request: compoundRequest,
                hasProAccess: hasProAccess,
                confirmedPlan: plan
            )
        }
        return "Added \(result.title). Anything else?"
    }
}
