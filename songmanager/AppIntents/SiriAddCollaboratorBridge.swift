import Foundation

@MainActor
enum SiriAddCollaboratorBridge {
    static func addCollaborator(
        artistName: String?,
        songwriterName: String?,
        pro: SiriPRO?,
        ipi: String?,
        defaultContributions: Set<Contribution>,
        songID: UUID?,
        hasProAccess: Bool
    ) throws -> CollaboratorAppEntity {
        let artist = artistName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let songwriter = songwriterName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !artist.isEmpty || !songwriter.isEmpty else { throw SiriDataError.missingCollaboratorName }
        let viewModel = AppStateViewModel.live()
        guard hasProAccess || viewModel.collaborators.count < FreeTierLimits.collaborators else { throw SiriDataError.freeCollaboratorLimitReached }
        let collaborator = try viewModel.addCollaboratorForSiri(
            artistName: artist,
            songwriterName: songwriter,
            preferredPRO: pro?.pro,
            ipi: ipi?.trimmingCharacters(in: .whitespacesAndNewlines),
            defaultContributions: defaultContributions,
            songID: songID
        )
        return CollaboratorAppEntity(collaborator: collaborator)
    }
}
