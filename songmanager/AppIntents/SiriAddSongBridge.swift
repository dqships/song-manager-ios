import Foundation

@MainActor
enum SiriAddSongBridge {
    static func addSong(title: String, phase: SiriSongPhase?, releaseDate: Date?, hasProAccess: Bool) throws -> SongAppEntity {
        let viewModel = AppStateViewModel.live()
        guard hasProAccess || viewModel.songs.count < FreeTierLimits.songs else { throw SiriDataError.freeSongLimitReached }
        guard hasProAccess || releaseDate == nil else { throw SiriDataError.proAccessRequired }
        let song = try viewModel.addSongForSiri(title: title, phase: phase?.songPhase ?? .pending, releaseDate: releaseDate, primaryContributions: hasProAccess ? viewModel.profile.defaultContributions : [])
        return SongAppEntity(song: song)
    }
}
