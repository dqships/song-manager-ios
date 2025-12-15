import CoreData
import Foundation

extension AppStateViewModel {
    func clearSongInformationForSiri(
        songID: UUID,
        field: SiriClearableSongField,
        collaboratorID: UUID?,
        linkTitle: String?
    ) throws {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        try performSiriMutation {
            switch field {
            case .releaseDate:
                song.releaseDate = nil
            case .notes:
                song.notes = ""
            case .isrc:
                song.isrc = nil
            case .iswc:
                song.iswc = nil
            case .upc:
                song.upc = nil
            case .musicLibraryLink:
                song.mediaLibraryPersistentID = 0
            case .savedWebLink:
                guard let linkTitle = SiriOptionalTextNormalizer.normalize(linkTitle) else {
                    throw SiriDataError.songLinkNotFound
                }
                let links = (song.externalLinks as? Set<SongLinkEntity>) ?? []
                guard let link = links.first(where: {
                    ($0.title ?? "").compare(linkTitle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                }) else { throw SiriDataError.songLinkNotFound }
                context.delete(link)
            case .registrationChecklist:
                song.checklistPro = false
                song.checklistMlc = false
                song.checklistHfa = false
                song.checklistSoundExchange = false
                song.checklistMusicReports = false
                song.checklistDistributorSubmitted = false
            case .collaboratorSplits:
                guard let collaboratorID else { throw SiriDataError.collaboratorNotFound }
                let links = (song.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
                guard let target = links.first(where: { $0.collaborator?.id == collaboratorID }) else {
                    throw SiriDataError.collaboratorNotOnSong
                }
                let otherLinks = links.filter { $0 != target }
                let otherMaster = otherLinks.reduce(0) { $0 + $1.masterSplit }
                let otherPublishing = otherLinks.reduce(0) { $0 + $1.publishingSplit }
                guard otherMaster <= 100, otherPublishing <= 100 else {
                    throw SiriDataError.splitTotalOverOneHundred
                }
                target.masterSplit = 0
                target.publishingSplit = 0
                song.primarySplitsMaster = 100 - otherMaster
                song.primarySplitsPublishing = 100 - otherPublishing
            }
        }
    }
}
