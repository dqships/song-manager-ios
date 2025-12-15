import AppIntents

struct AddSongIntent: AppIntent {
    static let title: LocalizedStringResource = "Add a Song"
    static let description = IntentDescription("Add a song to your ReleaseKit catalog.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Title", requestValueDialog: "What is the song called?") var title: String
    @Parameter(title: "Phase") var phase: SiriSongPhase?
    @Parameter(title: "Release date") var releaseDate: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$title)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let hasProAccess = await SiriSubscriptionAccess.hasProAccess()
        let song = try await MainActor.run { try SiriAddSongBridge.addSong(title: title, phase: phase, releaseDate: releaseDate, hasProAccess: hasProAccess) }
        return .result(dialog: "Added \(song.title) to your catalog. Anything else?")
    }
}
