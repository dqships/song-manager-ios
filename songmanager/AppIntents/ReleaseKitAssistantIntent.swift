import AppIntents

struct ReleaseKitAssistantIntent: AppIntent {
    static let title: LocalizedStringResource = "Use ReleaseKit With Siri"
    static let description = IntentDescription("Create, review, summarize, attach, or play catalog information through a spoken conversation.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Action", requestValueDialog: "What would you like to do?") var workflow: SiriAssistantWorkflow
    @Parameter(title: "Song description", requestValueDialog: "Describe the song, collaborator, role, and any split.") var request: String?
    @Parameter(title: "Song", requestValueDialog: "Which song?") var song: SongAppEntity?
    @Parameter(title: "Collaborator", requestValueDialog: "Which collaborator?") var collaborator: CollaboratorAppEntity?
    @Parameter(title: "First role") var contribution: SiriContribution?
    @Parameter(title: "Second role") var additionalContribution: SiriContribution?
    @Parameter(title: "Master split") var masterSplit: Double?
    @Parameter(title: "Publishing split") var publishingSplit: Double?
    @Parameter(title: "Ambiguous percentage applies to") var splitScope: SiriSplitScope?
    @Parameter(title: "Attention check") var attentionFilter: SiriAttentionFilter?
    @Parameter(title: "Production phase") var phase: SiriSongPhase?

    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$workflow) with ReleaseKit")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let dialog: IntentDialog
        switch workflow {
        case .describeSong:
            dialog = try await performDescribeSong()
        case .attachSavedCollaborator:
            dialog = try await performAttachSavedCollaborator()
        case .reviewCatalog:
            dialog = await performReviewCatalog()
        case .checkReleaseReadiness:
            dialog = try await performCheckReleaseReadiness()
        case .summarizeSong:
            dialog = try await performSummarizeSong()
        case .summarizeCollaborator:
            dialog = try await performSummarizeCollaborator()
        case .findSongsNeedingAttention:
            dialog = try await performFindSongsNeedingAttention()
        case .playImportedSong:
            dialog = try await performPlayImportedSong()
        case .pausePlayback:
            dialog = await performPausePlayback()
        case .resumePlayback:
            dialog = await performResumePlayback()
        }
        return .result(dialog: dialog)
    }
}
