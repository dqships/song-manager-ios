import Foundation

extension AppStateViewModel {
    func setRegistrationChecklistForSiri(
        songID: UUID,
        pro: Bool,
        mlc: Bool,
        hfa: Bool,
        soundExchange: Bool,
        musicReports: Bool,
        distributor: Bool
    ) throws {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }

        try performSiriMutation {
            song.checklistPro = pro
            song.checklistMlc = mlc
            song.checklistHfa = hfa
            song.checklistSoundExchange = soundExchange
            song.checklistMusicReports = musicReports
            song.checklistDistributorSubmitted = distributor
        }
    }
}
