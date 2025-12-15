import CoreData
import Foundation

extension AppStateViewModel {
    func removeSongLinkForSiri(songID: UUID, title: String) throws {
        let link = try songLinkForSiri(songID: songID, title: title)
        try performSiriMutation { context.delete(link) }
    }
}
