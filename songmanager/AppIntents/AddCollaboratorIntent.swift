import AppIntents

struct AddCollaboratorIntent: AppIntent {
    static let title: LocalizedStringResource = "Add a Collaborator"
    static let description = IntentDescription("Add a collaborator through a guided spoken conversation, and optionally add them to a song.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Artist name", requestValueDialog: "What artist name should I save?") var artistName: String
    @Parameter(title: "Add songwriter name", requestValueDialog: "Do they use a different legal or songwriter name?") var hasSongwriterName: Bool
    @Parameter(title: "Songwriter name", requestValueDialog: "What songwriter name should I save?") var songwriterName: String?
    @Parameter(title: "Add performance rights organization", requestValueDialog: "Do you want to save their performance rights organization?") var hasPRO: Bool
    @Parameter(title: "Performance rights organization", requestValueDialog: "Which performance rights organization?") var pro: SiriPRO?
    @Parameter(title: "Add IPI", requestValueDialog: "Do you want to save their IPI number?") var hasIPI: Bool
    @Parameter(title: "IPI number", requestValueDialog: "What is their IPI number?") var ipi: String?
    @Parameter(title: "Add default roles", requestValueDialog: "Do you want to save default song roles for them?") var hasDefaultRoles: Bool
    @Parameter(title: "First default role", requestValueDialog: "What default role should I save?") var contribution: SiriContribution?
    @Parameter(title: "Add another default role", requestValueDialog: "Do they have another default role?") var hasAdditionalContribution: Bool?
    @Parameter(title: "Second default role", requestValueDialog: "What other role should I save?") var additionalContribution: SiriContribution?
    @Parameter(title: "Add to a song", requestValueDialog: "Do you want to add them to a saved song now?") var shouldAttachToSong: Bool
    @Parameter(title: "Song", requestValueDialog: "Which song should I add them to?") var song: SongAppEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$artistName) as a collaborator")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let hasProAccess = await SiriSubscriptionAccess.hasProAccess()
        if hasSongwriterName, SiriOptionalTextNormalizer.normalize(songwriterName) == nil {
            throw $songwriterName.needsValueError("What songwriter name should I save?")
        }
        if hasPRO, pro == nil { throw $pro.needsValueError("Which performance rights organization?") }
        if hasIPI, SiriOptionalTextNormalizer.normalize(ipi) == nil {
            throw $ipi.needsValueError("What is their IPI number?")
        }
        if hasDefaultRoles, !hasProAccess { throw SiriDataError.proAccessRequired }
        if hasDefaultRoles, contribution == nil { throw $contribution.needsValueError("What default role should I save?") }
        if hasDefaultRoles, hasAdditionalContribution == nil {
            throw $hasAdditionalContribution.needsValueError("Do they have another default role?")
        }
        if hasDefaultRoles, hasAdditionalContribution == true, additionalContribution == nil {
            throw $additionalContribution.needsValueError("What other role should I save?")
        }
        if shouldAttachToSong, song == nil { throw $song.needsValueError("Which song should I add them to?") }
        let roles = Set([contribution?.contribution, hasAdditionalContribution == true ? additionalContribution?.contribution : nil].compactMap { $0 })
        let roleNames = await MainActor.run { roles.map(\.displayName).sorted().joined(separator: ", ") }
        let songwriterClause = hasSongwriterName ? ", songwriter name \(SiriOptionalTextNormalizer.normalize(songwriterName) ?? "")" : ""
        let proClause = hasPRO ? ", \(pro?.rawValue.uppercased() ?? "")" : ""
        let ipiClause = hasIPI ? ", IPI \(SiriOptionalTextNormalizer.normalize(ipi) ?? "")" : ""
        let roleClause = roles.isEmpty ? "" : ", default roles \(roleNames)"
        let songClause = shouldAttachToSong ? ", and add them to \(song?.title ?? "the song")" : ""
        try await requestConfirmation(
            result: .result(dialog: "Save \(artistName)\(songwriterClause)\(proClause)\(ipiClause)\(roleClause)\(songClause)?")
        )
        let collaborator = try await MainActor.run {
            try SiriAddCollaboratorBridge.addCollaborator(
                artistName: artistName,
                songwriterName: hasSongwriterName ? songwriterName : nil,
                pro: hasPRO ? pro : nil,
                ipi: hasIPI ? ipi : nil,
                defaultContributions: hasDefaultRoles ? roles : [],
                songID: shouldAttachToSong ? song?.id : nil,
                hasProAccess: hasProAccess
            )
        }
        let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
        return .result(dialog: "Added \(name) as a collaborator. Anything else?")
    }
}
