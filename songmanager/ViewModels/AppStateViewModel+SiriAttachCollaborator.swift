import CoreData
import Foundation

extension AppStateViewModel {
    func attachCollaboratorForSiri(
        collaboratorID: UUID,
        songID: UUID,
        contribution: Contribution?,
        splitScope: SiriSplitScope?,
        percentage: Double?,
        confirmedPreview: SiriSplitPreview?
    ) throws {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        let collaborator = try fetchCollaboratorForSiri(by: collaboratorID)
        let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
        if links.contains(where: { $0.collaborator?.id == collaboratorID }) {
            throw SiriDataError.collaboratorAlreadyOnSong
        }

        let master = splitScope == .master || splitScope == .both ? percentage ?? 0 : 0
        let publishing = splitScope == .publishing || splitScope == .both ? percentage ?? 0 : 0
        let currentMaster = links.reduce(0) { $0 + $1.masterSplit }
        let currentPublishing = links.reduce(0) { $0 + $1.publishingSplit }
        guard currentMaster + master <= 100, currentPublishing + publishing <= 100 else {
            throw SiriDataError.splitTotalOverOneHundred
        }
        if let confirmedPreview {
            let currentPreview = try previewAttachCollaboratorForSiri(
                collaboratorID: collaboratorID,
                songID: songID,
                splitScope: splitScope,
                percentage: percentage
            )
            guard currentPreview == confirmedPreview else { throw SiriDataError.requestChangedBeforeSave }
        }

        try performSiriMutation {
            let link = SongCollaboratorLinkEntity(context: context)
            link.id = UUID()
            link.song = song
            link.collaborator = collaborator
            link.masterSplit = master
            link.publishingSplit = publishing
            link.contributionsRaw = contribution.map { Self.encodeContributions([$0]) }
                ?? collaborator.defaultContributionsRaw
                ?? Self.encodeContributions([])
            song.primarySplitsMaster = 100 - currentMaster - master
            song.primarySplitsPublishing = 100 - currentPublishing - publishing
        }
    }
}
