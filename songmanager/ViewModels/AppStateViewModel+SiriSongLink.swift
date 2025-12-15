import CoreData
import Foundation

extension AppStateViewModel {
    func addSongLinkForSiri(songID: UUID, title: String, url: URL) throws {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        guard ["http", "https"].contains(url.scheme?.lowercased() ?? "") else { throw SiriDataError.invalidWebLink }
        let links = (song.externalLinks as? Set<SongLinkEntity>) ?? []
        guard links.count < 5 else { throw SiriDataError.songLinkLimitReached }

        try performSiriMutation {
            let link = SongLinkEntity(context: context)
            link.id = UUID()
            link.title = title
            link.urlString = url.absoluteString
            link.createdAt = Date()
            link.song = song
        }
    }
}
