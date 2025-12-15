import Foundation

extension AppStateViewModel {
    func updateSongContributionForSiri(songID: UUID, collaboratorID: UUID, contribution: Contribution) throws {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
        guard let link = links.first(where: { $0.collaborator?.id == collaboratorID }) else {
            throw SiriDataError.collaboratorNotOnSong
        }
        try performSiriMutation {
            link.contributionsRaw = Self.encodeContributions([contribution])
        }
    }
}
