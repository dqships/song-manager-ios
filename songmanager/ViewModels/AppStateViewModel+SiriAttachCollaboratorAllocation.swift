import CoreData
import Foundation

extension AppStateViewModel {
    func previewAttachCollaboratorAllocationForSiri(
        collaboratorID: UUID,
        songID: UUID,
        master: Double,
        publishing: Double
    ) throws -> SiriSplitPreview {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        _ = try fetchCollaboratorForSiri(by: collaboratorID)
        let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
        guard !links.contains(where: { $0.collaborator?.id == collaboratorID }) else {
            throw SiriDataError.collaboratorAlreadyOnSong
        }
        guard master.isFinite, publishing.isFinite,
              (0 ... 100).contains(master), (0 ... 100).contains(publishing) else {
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

    func attachCollaboratorAllocationForSiri(
        collaboratorID: UUID,
        songID: UUID,
        contributions: Set<Contribution>,
        master: Double,
        publishing: Double,
        confirmedPreview: SiriSplitPreview
    ) throws {
        let currentPreview = try previewAttachCollaboratorAllocationForSiri(
            collaboratorID: collaboratorID,
            songID: songID,
            master: master,
            publishing: publishing
        )
        guard currentPreview == confirmedPreview else { throw SiriDataError.requestChangedBeforeSave }
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        let collaborator = try fetchCollaboratorForSiri(by: collaboratorID)
        try performSiriMutation {
            let link = SongCollaboratorLinkEntity(context: context)
            link.id = UUID()
            link.song = song
            link.collaborator = collaborator
            link.masterSplit = master
            link.publishingSplit = publishing
            link.contributionsRaw = contributions.isEmpty
                ? collaborator.defaultContributionsRaw ?? Self.encodeContributions([])
                : Self.encodeContributions(contributions)
            song.primarySplitsMaster = currentPreview.primaryMaster
            song.primarySplitsPublishing = currentPreview.primaryPublishing
        }
    }
}
