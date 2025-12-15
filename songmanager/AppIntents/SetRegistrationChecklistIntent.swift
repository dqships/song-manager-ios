import AppIntents

struct SetRegistrationChecklistIntent: AppIntent {
    static let title: LocalizedStringResource = "Update a Registration Checklist"
    static let description = IntentDescription("Mark one song registration item complete or incomplete.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Song", requestValueDialog: "Which song?") var song: SongAppEntity
    @Parameter(title: "Registration item", requestValueDialog: "Which registration item?") var item: SiriRegistrationItem
    @Parameter(title: "Complete", requestValueDialog: "Should I mark it complete or incomplete?") var isComplete: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$item) for \(\.$song) to \(\.$isComplete)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await MainActor.run {
            try AppStateViewModel.live().setRegistrationItemForSiri(songID: song.id, item: item, isComplete: isComplete)
        }
        let state = isComplete ? "complete" : "incomplete"
        return .result(dialog: "Marked \(item.dialogName) for \(song.title) as \(state). Anything else?")
    }
}
