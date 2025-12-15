import Foundation

extension AppStateViewModel {
    func updatePrimarySongContributionForSiri(songID: UUID, contribution: Contribution) throws {
        guard let song = fetchSong(by: songID) else { throw SiriDataError.songNotFound }
        try performSiriMutation {
            song.primaryContributionsRaw = Self.encodeContributions([contribution])
        }
    }
}
