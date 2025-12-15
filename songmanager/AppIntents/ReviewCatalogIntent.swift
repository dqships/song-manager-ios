import AppIntents

struct ReviewCatalogIntent: AppIntent {
    static let title: LocalizedStringResource = "Review Catalog"
    static let description = IntentDescription("Review the songs that need attention in ReleaseKit.")

    @Parameter(title: "Phase") var phase: SiriSongPhase?

    static var parameterSummary: some ParameterSummary {
        Summary("Review my catalog")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let summary = await MainActor.run {
            let songs = AppStateViewModel.live().songs
            let filtered = phase.map { selected in songs.filter { $0.phase == selected.songPhase } } ?? songs
            let names = filtered.prefix(3).map(\.title).joined(separator: ", ")
            return names.isEmpty ? "You have no matching songs." : "You have \(filtered.count) matching songs: \(names)."
        }
        return .result(dialog: "\(summary) Anything else?")
    }
}
