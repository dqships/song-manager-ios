import AppIntents

struct ProtectedCatalogChangeIntent: AppIntent {
    static let title: LocalizedStringResource = "Delete or Clear ReleaseKit Information"
    static let description = IntentDescription("Delete one catalog record or clear selected information after device authentication and confirmation.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresLocalDeviceAuthentication }

    @Parameter(title: "Action", requestValueDialog: "Should I delete a record or clear selected information?") var action: SiriProtectedCatalogAction
    @Parameter(title: "Song", requestValueDialog: "Which song?") var song: SongAppEntity?
    @Parameter(title: "Collaborator", requestValueDialog: "Which collaborator?") var collaborator: CollaboratorAppEntity?
    @Parameter(title: "Song information", requestValueDialog: "Which song information should I clear?") var songField: SiriClearableSongField?
    @Parameter(title: "Collaborator information", requestValueDialog: "Which collaborator information should I clear?") var collaboratorField: SiriClearableCollaboratorField?
    @Parameter(title: "Saved link name", requestValueDialog: "What is the saved link called?") var linkTitle: String?
    @Parameter(title: "Song for collaborator roles", requestValueDialog: "Which song has those roles?") var collaboratorSong: SongAppEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$action) in ReleaseKit")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        switch action {
        case .deleteSong:
            guard let song else { throw $song.needsValueError("Which song should I delete?") }
            try await requestConfirmation(result: .result(dialog: "Delete \(song.title), including its links and collaborator assignments? This cannot be undone."))
            try await MainActor.run { try AppStateViewModel.live().deleteSongForSiri(id: song.id) }
            return .result(dialog: "Deleted \(song.title). Anything else?")

        case .deleteCollaborator:
            guard let collaborator else { throw $collaborator.needsValueError("Which collaborator should I delete?") }
            let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
            let songCount = await MainActor.run {
                AppStateViewModel.live().songs.filter { savedSong in
                    savedSong.collaborators.contains(where: { $0.id == collaborator.id })
                }.count
            }
            try await requestConfirmation(result: .result(dialog: "Delete \(name)? This removes their credit from \(songCount) song\(songCount == 1 ? "" : "s") and cannot be undone."))
            try await MainActor.run { try AppStateViewModel.live().deleteCollaboratorForSiri(id: collaborator.id) }
            return .result(dialog: "Deleted \(name). Anything else?")

        case .clearSongInformation:
            guard let song else { throw $song.needsValueError("Which song should I update?") }
            guard let songField else { throw $songField.needsValueError("Which song information should I clear?") }
            if songField == .savedWebLink, SiriOptionalTextNormalizer.normalize(linkTitle) == nil {
                throw $linkTitle.needsValueError("What is the saved link called?")
            }
            if songField == .collaboratorSplits, collaborator == nil {
                throw $collaborator.needsValueError("Which collaborator's splits should I reset?")
            }
            try await requestConfirmation(result: .result(dialog: "Clear \(songField.dialogName) from \(song.title)?"))
            try await MainActor.run {
                try AppStateViewModel.live().clearSongInformationForSiri(
                    songID: song.id,
                    field: songField,
                    collaboratorID: collaborator?.id,
                    linkTitle: linkTitle
                )
            }
            return .result(dialog: "Cleared that information from \(song.title). Anything else?")

        case .clearCollaboratorInformation:
            guard let collaborator else { throw $collaborator.needsValueError("Which collaborator should I update?") }
            guard let collaboratorField else {
                throw $collaboratorField.needsValueError("Which collaborator information should I clear?")
            }
            if collaboratorField == .rolesOnSong, collaboratorSong == nil {
                throw $collaboratorSong.needsValueError("Which song has those roles?")
            }
            let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
            try await requestConfirmation(result: .result(dialog: "Clear \(collaboratorField.dialogName) for \(name)?"))
            try await MainActor.run {
                try AppStateViewModel.live().clearCollaboratorInformationForSiri(
                    collaboratorID: collaborator.id,
                    field: collaboratorField,
                    songID: collaboratorSong?.id
                )
            }
            return .result(dialog: "Cleared that information for \(name). Anything else?")
        }
    }
}
