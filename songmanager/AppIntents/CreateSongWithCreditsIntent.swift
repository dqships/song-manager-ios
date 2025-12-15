import AppIntents

struct CreateSongWithCreditsIntent: AppIntent {
    static let title: LocalizedStringResource = "Add a Song With Credits"
    static let description = IntentDescription("Create a song with an optional collaborator, role, and separate master and publishing splits.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    static var isDiscoverable: Bool { false }

    @Parameter(title: "Title", requestValueDialog: "What is the song title?") var title: String
    @Parameter(title: "Phase") var phase: SiriSongPhase?
    @Parameter(title: "Release date") var releaseDate: Date?
    @Parameter(title: "Existing collaborator") var existingCollaborator: CollaboratorAppEntity?
    @Parameter(title: "New collaborator artist name", requestValueDialog: "What is the collaborator's artist name?") var collaboratorArtistName: String?
    @Parameter(title: "New collaborator songwriter name") var collaboratorSongwriterName: String?
    @Parameter(title: "New collaborator PRO") var collaboratorPRO: SiriPRO?
    @Parameter(title: "New collaborator IPI") var collaboratorIPI: String?
    @Parameter(title: "Collaborator role", requestValueDialog: "What is the collaborator's role?") var contribution: SiriContribution?
    @Parameter(title: "Second collaborator role") var additionalContribution: SiriContribution?
    @Parameter(title: "Master split") var masterSplit: Double?
    @Parameter(title: "Publishing split") var publishingSplit: Double?

    static var parameterSummary: some ParameterSummary { Summary("Add \(\.$title) with credits") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let hasProAccess = await SiriSubscriptionAccess.hasProAccess()
        let request = SiriCreateSongWithCreditsRequest(
            title: title,
            phase: phase?.songPhase ?? .pending,
            releaseDate: releaseDate,
            existingCollaboratorID: existingCollaborator?.id,
            collaboratorArtistName: collaboratorArtistName,
            collaboratorSongwriterName: collaboratorSongwriterName,
            collaboratorPRO: collaboratorPRO?.pro,
            collaboratorIPI: collaboratorIPI,
            contributions: Set([contribution?.contribution, additionalContribution?.contribution].compactMap { $0 }),
            masterSplit: masterSplit,
            publishingSplit: publishingSplit
        )
        let plan = try await MainActor.run {
            try AppStateViewModel.live().planSongWithCreditsForSiri(request: request, hasProAccess: hasProAccess)
        }
        let confirmation: IntentDialog = "\(plan.confirmation)"
        try await requestConfirmation(result: .result(dialog: confirmation))
        let result = try await MainActor.run {
            try AppStateViewModel.live().createSongWithCreditsForSiri(
                request: request,
                hasProAccess: hasProAccess,
                confirmedPlan: plan
            )
        }
        return .result(dialog: "Added \(result.title) to your catalog. Anything else?")
    }
}
