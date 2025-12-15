import CoreData
import Foundation

extension AppStateViewModel {
    func updateSongLinkForSiri(songID: UUID, title: String, url: URL) throws {
        guard ["http", "https"].contains(url.scheme?.lowercased() ?? "") else { throw SiriDataError.invalidWebLink }
        let link = try songLinkForSiri(songID: songID, title: title)
        try performSiriMutation {
            link.urlString = url.absoluteString
        }
    }
}
