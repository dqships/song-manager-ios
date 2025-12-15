import Foundation
import CoreData

extension AppStateViewModel {
    func addSongForSiri(title: String, phase: SongPhase, releaseDate: Date?, primaryContributions: Set<Contribution>) throws -> Song {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { throw SiriDataError.missingSongTitle }

        let song = SongEntity(context: context)
        song.id = UUID()
        song.title = trimmedTitle
        song.createdAt = Date()
        song.phase = phase.rawValue
        song.releaseDate = releaseDate
        song.primaryArtist = profile.artistName
        song.primarySongwriter = profile.songwriterName
        song.distributorPreset = profile.distributor.preset.rawValue
        song.distributorCustomName = profile.distributor.customName
        song.primarySplitsMaster = 100
        song.primarySplitsPublishing = 100
        song.primaryContributionsRaw = Self.encodeContributions(primaryContributions)
        song.notes = ""
        try performSiriMutation { }
        guard let savedSong = songs.first(where: { $0.id == song.id }) else { throw SiriDataError.songNotFound }
        return savedSong
    }
}
