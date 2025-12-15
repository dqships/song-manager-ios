import AppIntents

struct DeleteCollaboratorIntent: AppIntent {
    static let title: LocalizedStringResource = "Delete a Collaborator"
    static let description = IntentDescription("Permanently delete one collaborator from ReleaseKit.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresLocalDeviceAuthentication }

    @Parameter(title: "Collaborator", requestValueDialog: "Which collaborator should I delete?") var collaborator: CollaboratorAppEntity

    static var parameterSummary: some ParameterSummary { Summary("Delete \(\.$collaborator)") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
        try await requestConfirmation(result: .result(dialog: "Delete \(name)? This cannot be undone."))
        try await MainActor.run { try AppStateViewModel.live().deleteCollaboratorForSiri(id: collaborator.id) }
        return .result(dialog: "Deleted \(name). Anything else?")
    }
}
