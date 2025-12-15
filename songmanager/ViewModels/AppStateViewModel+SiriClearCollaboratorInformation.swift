import CoreData
import Foundation

extension AppStateViewModel {
    func clearCollaboratorInformationForSiri(
        collaboratorID: UUID,
        field: SiriClearableCollaboratorField,
        songID: UUID?
    ) throws {
        let collaborator = try fetchCollaboratorForSiri(by: collaboratorID)
        try performSiriMutation {
            switch field {
            case .songwriterName:
                collaborator.songwriterName = ""
            case .pro:
                collaborator.preferredPRO = nil
            case .ipi:
                collaborator.ipi = nil
            case .defaultRoles:
                collaborator.defaultContributionsRaw = Self.encodeContributions([])
            case .rolesOnSong:
                guard let songID, let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
                let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
                guard let link = links.first(where: { $0.collaborator?.id == collaboratorID }) else {
                    throw SiriDataError.collaboratorNotOnSong
                }
                link.contributionsRaw = Self.encodeContributions([])
            }
        }
    }
}
