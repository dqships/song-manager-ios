import Foundation

extension AppStateViewModel {
    func previewSongSplitsForSiri(songID: UUID, collaboratorID: UUID, master: Double?, publishing: Double?) throws -> SiriSplitPreview {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
        guard let link = links.first(where: { $0.collaborator?.id == collaboratorID }) else {
            throw SiriDataError.collaboratorNotOnSong
        }

        let collaboratorMaster = master ?? link.masterSplit
        let collaboratorPublishing = publishing ?? link.publishingSplit
        guard collaboratorMaster.isFinite, collaboratorPublishing.isFinite,
              (0...100).contains(collaboratorMaster), (0...100).contains(collaboratorPublishing) else {
            throw SiriDataError.invalidSplit
        }

        let otherLinks = links.filter { $0.collaborator?.id != collaboratorID }
        let otherMaster = otherLinks.reduce(0) { $0 + $1.masterSplit }
        let otherPublishing = otherLinks.reduce(0) { $0 + $1.publishingSplit }
        guard otherMaster + collaboratorMaster <= 100,
              otherPublishing + collaboratorPublishing <= 100 else {
            throw SiriDataError.splitTotalOverOneHundred
        }

        return SiriSplitPreview(
            collaboratorMaster: collaboratorMaster,
            collaboratorPublishing: collaboratorPublishing,
            primaryMaster: 100 - otherMaster - collaboratorMaster,
            primaryPublishing: 100 - otherPublishing - collaboratorPublishing
        )
    }
}
