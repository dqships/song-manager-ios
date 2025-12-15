import Foundation

extension AppStateViewModel {
    func setRegistrationItemForSiri(songID: UUID, item: SiriRegistrationItem, isComplete: Bool) throws {
        guard let song = fetchSong(by: songID) else {
            throw SiriDataError.songNotFound
        }

        try performSiriMutation {
            switch item {
            case .pro: song.checklistPro = isComplete
            case .mlc: song.checklistMlc = isComplete
            case .hfa: song.checklistHfa = isComplete
            case .soundExchange: song.checklistSoundExchange = isComplete
            case .musicReports: song.checklistMusicReports = isComplete
            case .distributor: song.checklistDistributorSubmitted = isComplete
            }
        }
    }
}
