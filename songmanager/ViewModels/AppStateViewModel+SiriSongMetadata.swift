import Foundation

extension AppStateViewModel {
    func updateSongMetadataForSiri(
        id: UUID,
        title: String?,
        releaseDate: Date?,
        primaryArtist: String?,
        primarySongwriter: String?,
        distributor: Distributor?,
        isrc: String?,
        iswc: String?,
        upc: String?,
        notes: String?
    ) throws {
        guard let song = fetchSong(by: id) else {
            throw SiriDataError.songNotFound
        }

        try performSiriMutation {
            if let title = title?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty { song.title = title }
            if let releaseDate { song.releaseDate = releaseDate }
            if let primaryArtist = primaryArtist?.trimmingCharacters(in: .whitespacesAndNewlines), !primaryArtist.isEmpty { song.primaryArtist = primaryArtist }
            if let primarySongwriter = primarySongwriter?.trimmingCharacters(in: .whitespacesAndNewlines), !primarySongwriter.isEmpty { song.primarySongwriter = primarySongwriter }
            if let distributor {
                song.distributorPreset = distributor.preset.rawValue
                song.distributorCustomName = distributor.customName
            }
            if let isrc = isrc?.trimmingCharacters(in: .whitespacesAndNewlines), !isrc.isEmpty { song.isrc = isrc }
            if let iswc = iswc?.trimmingCharacters(in: .whitespacesAndNewlines), !iswc.isEmpty { song.iswc = iswc }
            if let upc = upc?.trimmingCharacters(in: .whitespacesAndNewlines), !upc.isEmpty { song.upc = upc }
            if let notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty { song.notes = notes }
        }
    }
}
