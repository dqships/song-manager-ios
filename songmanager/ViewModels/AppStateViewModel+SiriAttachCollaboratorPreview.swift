import Foundation

extension AppStateViewModel {
    func previewAttachCollaboratorForSiri(
        collaboratorID: UUID,
        songID: UUID,
        splitScope: SiriSplitScope?,
        percentage: Double?
    ) throws -> SiriSplitPreview {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        _ = try fetchCollaboratorForSiri(by: collaboratorID)
        let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
        guard !links.contains(where: { $0.collaborator?.id == collaboratorID }) else {
            throw SiriDataError.collaboratorAlreadyOnSong
        }

        let master = splitScope == .master || splitScope == .both ? percentage ?? 0 : 0
        let publishing = splitScope == .publishing || splitScope == .both ? percentage ?? 0 : 0
        guard master.isFinite, publishing.isFinite,
              (0...100).contains(master), (0...100).contains(publishing) else {
            throw SiriDataError.invalidSplit
        }

        let currentMaster = links.reduce(0) { $0 + $1.masterSplit }
        let currentPublishing = links.reduce(0) { $0 + $1.publishingSplit }
        guard currentMaster + master <= 100, currentPublishing + publishing <= 100 else {
            throw SiriDataError.splitTotalOverOneHundred
        }

        return SiriSplitPreview(
            collaboratorMaster: master,
            collaboratorPublishing: publishing,
            primaryMaster: 100 - currentMaster - master,
            primaryPublishing: 100 - currentPublishing - publishing
        )
    }
}
