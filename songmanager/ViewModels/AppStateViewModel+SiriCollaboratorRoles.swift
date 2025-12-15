import Foundation

extension AppStateViewModel {
    func updateCollaboratorRolesForSiri(
        collaboratorID: UUID,
        songID: UUID?,
        roles: Set<Contribution>,
        change: SiriRoleChange
    ) throws {
        guard !roles.isEmpty else { throw SiriDataError.noUpdateFields }

        if let songID {
            guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
            let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
            guard let link = links.first(where: { $0.collaborator?.id == collaboratorID }) else {
                throw SiriDataError.collaboratorNotOnSong
            }
            try performSiriMutation {
                let current = Self.decodeContributions(link.contributionsRaw)
                link.contributionsRaw = Self.encodeContributions(SiriRoleSet.applying(roles, to: current, change: change))
            }
            return
        }

        let collaborator = try fetchCollaboratorForSiri(by: collaboratorID)
        try performSiriMutation {
            let current = Self.decodeContributions(collaborator.defaultContributionsRaw)
            collaborator.defaultContributionsRaw = Self.encodeContributions(SiriRoleSet.applying(roles, to: current, change: change))
        }
    }
}
