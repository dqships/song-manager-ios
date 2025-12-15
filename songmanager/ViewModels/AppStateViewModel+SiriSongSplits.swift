import Foundation

extension AppStateViewModel {
    func updateSongSplitsForSiri(
        songID: UUID,
        collaboratorID: UUID,
        master: Double?,
        publishing: Double?,
        confirmedPreview: SiriSplitPreview
    ) throws {
        let currentPreview = try previewSongSplitsForSiri(
            songID: songID,
            collaboratorID: collaboratorID,
            master: master,
            publishing: publishing
        )
        guard currentPreview == confirmedPreview else { throw SiriDataError.requestChangedBeforeSave }
        guard let song = fetchSong(by: songID) else {
            throw SiriDataError.songNotFound
        }

        let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
        guard let link = links.first(where: { $0.collaborator?.id == collaboratorID }) else {
            throw SiriDataError.collaboratorNotOnSong
        }
        try performSiriMutation {
            link.masterSplit = currentPreview.collaboratorMaster
            link.publishingSplit = currentPreview.collaboratorPublishing
            song.primarySplitsMaster = currentPreview.primaryMaster
            song.primarySplitsPublishing = currentPreview.primaryPublishing
        }
    }
}
