import AppIntents

struct UpdateCollaboratorMetadataIntent: AppIntent {
    static let title: LocalizedStringResource = "Update a Collaborator"
    static let description = IntentDescription("Change one saved collaborator detail or their role on a song.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Collaborator", requestValueDialog: "Which collaborator?") var collaborator: CollaboratorAppEntity
    @Parameter(title: "Detail", requestValueDialog: "Which collaborator detail should I change?") var field: SiriCollaboratorMetadataField
    @Parameter(title: "Text value", requestValueDialog: "What should I save?") var textValue: String?
    @Parameter(title: "Performance rights organization", requestValueDialog: "Which performance rights organization?") var proValue: SiriPRO?
    @Parameter(title: "Role", requestValueDialog: "What role should I save?") var contributionValue: SiriContribution?
    @Parameter(title: "Role change", requestValueDialog: "Should I add, remove, or replace the role?") var roleChange: SiriRoleChange?
    @Parameter(title: "Song", requestValueDialog: "Which song?") var song: SongAppEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Update \(\.$field) for \(\.$collaborator)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let changesRole = field == .defaultRole || field == .roleOnSong
        if changesRole, !(await SiriSubscriptionAccess.hasProAccess()) {
            throw SiriDataError.proAccessRequired
        }
        if changesRole, roleChange == nil {
            throw $roleChange.needsValueError("Should I add, remove, or replace the role?")
        }

        switch field {
        case .artistName:
            guard let textValue = SiriOptionalTextNormalizer.normalize(textValue) else {
                throw $textValue.needsValueError("What artist name should I save?")
            }
            try await update(artistName: textValue)
        case .songwriterName:
            guard let textValue = SiriOptionalTextNormalizer.normalize(textValue) else {
                throw $textValue.needsValueError("What songwriter name should I save?")
            }
            try await update(songwriterName: textValue)
        case .pro:
            guard let proValue else {
                throw $proValue.needsValueError("Which performance rights organization?")
            }
            try await update(pro: proValue.pro)
        case .ipi:
            guard let textValue = SiriOptionalTextNormalizer.normalize(textValue) else {
                throw $textValue.needsValueError("What IPI number should I save?")
            }
            try await update(ipi: textValue)
        case .defaultRole:
            guard let contributionValue else {
                throw $contributionValue.needsValueError("What default role should I save?")
            }
            let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
            try await requestConfirmation(
                result: .result(dialog: "\(roleConfirmation(for: name, role: contributionValue, songTitle: nil))")
            )
            try await updateRoles(songID: nil, contribution: contributionValue)
        case .roleOnSong:
            guard let song else { throw $song.needsValueError("Which song?") }
            guard let contributionValue else {
                throw $contributionValue.needsValueError("What role should I save for this song?")
            }
            let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
            try await requestConfirmation(
                result: .result(dialog: "\(roleConfirmation(for: name, role: contributionValue, songTitle: song.title))")
            )
            try await updateRoles(songID: song.id, contribution: contributionValue)
        }

        let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
        return .result(dialog: "Updated \(name). Anything else?")
    }

    private func updateRoles(songID: UUID?, contribution: SiriContribution) async throws {
        guard let roleChange else { throw SiriDataError.noUpdateFields }
        try await MainActor.run {
            try AppStateViewModel.live().updateCollaboratorRolesForSiri(
                collaboratorID: collaborator.id,
                songID: songID,
                roles: [contribution.contribution],
                change: roleChange
            )
        }
    }

    private func roleConfirmation(for name: String, role: SiriContribution, songTitle: String?) -> String {
        guard let roleChange else { return "Update \(role.dialogName) for \(name)?" }
        return SiriRoleChangeConfirmationFormatter.format(
            change: roleChange,
            collaboratorName: name,
            roleName: role.dialogName,
            songTitle: songTitle
        )
    }

    private func update(
        artistName: String? = nil,
        songwriterName: String? = nil,
        pro: PRO? = nil,
        ipi: String? = nil,
        defaultContribution: Contribution? = nil
    ) async throws {
        try await MainActor.run {
            try AppStateViewModel.live().updateCollaboratorMetadataForSiri(
                id: collaborator.id,
                artistName: artistName,
                songwriterName: songwriterName,
                preferredPRO: pro,
                ipi: ipi,
                defaultContribution: defaultContribution
            )
        }
    }
}
