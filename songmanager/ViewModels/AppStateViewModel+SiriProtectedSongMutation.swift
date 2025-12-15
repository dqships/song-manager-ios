import CoreData
import Foundation

extension AppStateViewModel {
    func deleteSongForSiri(id: UUID) throws {
        guard let song = fetchSong(by: id) else { throw SiriDataError.songNotFound }
        try performSiriMutation { context.delete(song) }
    }

    func resetRegistrationChecklistForSiri(songID: UUID) throws {
        try setRegistrationChecklistForSiri(
            songID: songID,
            pro: false,
            mlc: false,
            hfa: false,
            soundExchange: false,
            musicReports: false,
            distributor: false
        )
    }
}
