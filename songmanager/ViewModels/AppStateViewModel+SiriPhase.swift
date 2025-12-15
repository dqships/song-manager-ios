import Foundation

extension AppStateViewModel {
    func updateSongPhaseForSiri(id: UUID, phase: SongPhase) throws {
        guard let song = fetchSong(by: id) else { throw SiriDataError.songNotFound }
        try performSiriMutation {
            song.phase = phase.rawValue
        }
    }
}
