import CoreData
import Foundation

extension AppStateViewModel {
    func songLinkForSiri(songID: UUID, title: String) throws -> SongLinkEntity {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        let normalizedTitle = SiriOptionalTextNormalizer.normalize(title) ?? ""
        guard !normalizedTitle.isEmpty else { throw SiriDataError.noUpdateFields }
        let links = (song.externalLinks as? Set<SongLinkEntity>) ?? []
        guard let link = links.first(where: { link in
            guard let title = link.title else { return false }
            return title.compare(normalizedTitle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }) else {
            throw SiriDataError.songLinkNotFound
        }
        return link
    }
}
