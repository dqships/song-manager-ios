import AppIntents

struct CompleteRegistrationChecklistIntent: AppIntent {
    static let title: LocalizedStringResource = "Complete a Registration Checklist"
    static let description = IntentDescription("Review and save all six registration items for one song at once.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Song", requestValueDialog: "Which song should I review?") var song: SongAppEntity
    @Parameter(title: "PRO registration", requestValueDialog: "Is PRO registration complete?") var pro: Bool
    @Parameter(title: "MLC registration", requestValueDialog: "Is MLC registration complete?") var mlc: Bool
    @Parameter(title: "HFA registration", requestValueDialog: "Is HFA registration complete?") var hfa: Bool
    @Parameter(title: "SoundExchange registration", requestValueDialog: "Is SoundExchange registration complete?") var soundExchange: Bool
    @Parameter(title: "Music Reports registration", requestValueDialog: "Is Music Reports registration complete?") var musicReports: Bool
    @Parameter(title: "Distributor submission", requestValueDialog: "Has the distributor submission been completed?") var distributor: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Review registration for \(\.$song)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await requestConfirmation(result: .result(dialog: "Save all six registration answers for \(song.title)?"))
        try await MainActor.run {
            try AppStateViewModel.live().setRegistrationChecklistForSiri(
                songID: song.id,
                pro: pro,
                mlc: mlc,
                hfa: hfa,
                soundExchange: soundExchange,
                musicReports: musicReports,
                distributor: distributor
            )
        }
        return .result(dialog: "Saved the registration checklist for \(song.title). Anything else?")
    }
}
