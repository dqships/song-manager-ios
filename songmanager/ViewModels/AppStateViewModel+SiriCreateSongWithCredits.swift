import CoreData
import Foundation

extension AppStateViewModel {
    func createSongWithCreditsForSiri(
        request: SiriCreateSongWithCreditsRequest,
        hasProAccess: Bool,
        confirmedPlan: SiriSongCreditPlan
    ) throws -> SiriCreateSongWithCreditsResult {
        let plan = try planSongWithCreditsForSiri(request: request, hasProAccess: hasProAccess)
        guard plan == confirmedPlan else { throw SiriDataError.requestChangedBeforeSave }
        let song = SongEntity(context: context)
        let songID = UUID()
        song.id = songID
        song.title = plan.title
        song.createdAt = Date()
        song.releaseDate = plan.request.releaseDate
        song.phase = plan.request.phase.rawValue
        song.primaryArtist = plan.profileArtistName
        song.primarySongwriter = plan.profileSongwriterName
        song.distributorPreset = plan.profileDistributor.preset.rawValue
        song.distributorCustomName = plan.profileDistributor.customName
        song.checklistPro = false
        song.checklistMlc = false
        song.checklistHfa = false
        song.checklistSoundExchange = false
        song.checklistMusicReports = false
        song.checklistDistributorSubmitted = false
        song.primarySplitsMaster = 100 - plan.masterSplit
        song.primarySplitsPublishing = 100 - plan.publishingSplit
        song.primaryContributionsRaw = Self.encodeContributions(plan.primaryContributions)
        song.notes = ""

        var collaboratorName: String?
        do {
            let collaboratorEntity: CollaboratorEntity?
            if plan.createsCollaborator {
                let collaborator = CollaboratorEntity(context: context)
                collaborator.id = UUID()
                collaborator.artistName = plan.collaboratorArtistName ?? ""
                collaborator.songwriterName = plan.collaboratorSongwriterName ?? ""
                collaborator.preferredPRO = plan.request.collaboratorPRO?.rawValue
                collaborator.ipi = SiriOptionalTextNormalizer.normalize(plan.request.collaboratorIPI)
                collaborator.defaultContributionsRaw = Self.encodeContributions([])
                collaborator.createdAt = Date()
                collaboratorEntity = collaborator
            } else if let collaboratorID = plan.collaboratorID {
                collaboratorEntity = try fetchCollaboratorForSiri(by: collaboratorID)
            } else {
                collaboratorEntity = nil
            }

            if let collaboratorEntity {
                let link = SongCollaboratorLinkEntity(context: context)
                link.id = UUID()
                link.song = song
                link.collaborator = collaboratorEntity
                link.masterSplit = plan.masterSplit
                link.publishingSplit = plan.publishingSplit
                link.contributionsRaw = Self.encodeContributions(plan.collaboratorContributions)
                collaboratorName = SiriOptionalTextNormalizer.normalize(collaboratorEntity.artistName)
                    ?? SiriOptionalTextNormalizer.normalize(collaboratorEntity.songwriterName)
            }

            try saveAndRefresh()
            return SiriCreateSongWithCreditsResult(songID: songID, title: plan.title, collaboratorName: collaboratorName)
        } catch {
            context.rollback()
            try? saveAndRefresh()
            throw error
        }
    }
}
