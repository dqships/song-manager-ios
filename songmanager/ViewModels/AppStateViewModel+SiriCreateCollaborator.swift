import Foundation
import CoreData

extension AppStateViewModel {
    func addCollaboratorForSiri(
        artistName: String,
        songwriterName: String,
        preferredPRO: PRO?,
        ipi: String?,
        defaultContributions: Set<Contribution>,
        songID: UUID?
    ) throws -> Collaborator {
        if let songID, fetchSong(by: songID) == nil { throw SiriDataError.songNotFound }
        let collaborator = CollaboratorEntity(context: context)
        collaborator.id = UUID()
        collaborator.artistName = artistName
        collaborator.songwriterName = songwriterName
        collaborator.preferredPRO = preferredPRO?.rawValue
        collaborator.defaultContributionsRaw = Self.encodeContributions(defaultContributions)
        collaborator.ipi = ipi
        collaborator.createdAt = Date()
        do {
            if let songID {
                guard let song = fetchSong(by: songID), let collaboratorID = collaborator.id else { throw SiriDataError.songNotFound }
                attachCollaborators(
                    to: song,
                    collaboratorIDs: [collaboratorID],
                    splits: [:],
                    contributions: [collaboratorID: defaultContributions]
                )
            }
            try saveAndRefresh()
            guard let savedCollaborator = collaborators.first(where: { $0.id == collaborator.id }) else { throw SiriDataError.collaboratorNotFound }
            return savedCollaborator
        } catch {
            context.rollback()
            try? saveAndRefresh()
            throw error
        }
    }
}
