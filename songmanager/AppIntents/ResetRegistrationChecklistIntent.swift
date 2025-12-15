import AppIntents

struct ResetRegistrationChecklistIntent: AppIntent {
    static let title: LocalizedStringResource = "Reset a Registration Checklist"
    static let description = IntentDescription("Mark all six registration items incomplete for one song.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresLocalDeviceAuthentication }

    @Parameter(title: "Song", requestValueDialog: "Which song's checklist should I reset?") var song: SongAppEntity

    static var parameterSummary: some ParameterSummary { Summary("Reset registration for \(\.$song)") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await requestConfirmation(result: .result(dialog: "Reset all six registration items for \(song.title)?"))
        try await MainActor.run { try AppStateViewModel.live().resetRegistrationChecklistForSiri(songID: song.id) }
        return .result(dialog: "Reset the registration checklist for \(song.title). Anything else?")
    }
}
