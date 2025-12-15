import Foundation
import CoreData

extension AppStateViewModel {
    func updateProfileForSiri(
        artistName: String?,
        songwriterName: String?,
        mainPRO: PRO?,
        distributor: Distributor?,
        ipi: String?,
        defaultContribution: Contribution?
    ) throws {
        guard let profileObjectID, let profileObject = try context.existingObject(with: profileObjectID) as? UserProfileEntity else {
            throw SiriDataError.profileNotFound
        }
        try performSiriMutation {
            if let artistName = artistName?.trimmingCharacters(in: .whitespacesAndNewlines), !artistName.isEmpty { profileObject.artistName = artistName }
            if let songwriterName = songwriterName?.trimmingCharacters(in: .whitespacesAndNewlines), !songwriterName.isEmpty { profileObject.songwriterName = songwriterName }
            if let mainPRO { profileObject.mainPRO = mainPRO.rawValue }
            if let distributor { profileObject.distributorPreset = distributor.preset.rawValue; profileObject.distributorCustomName = distributor.customName }
            if let ipi = ipi?.trimmingCharacters(in: .whitespacesAndNewlines), !ipi.isEmpty { profileObject.ipi = ipi }
            if let defaultContribution { profileObject.defaultContributionsRaw = Self.encodeContributions([defaultContribution]) }

            if artistName != nil || songwriterName != nil || distributor != nil {
                let songRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
                let songs = try context.fetch(songRequest)
                for song in songs {
                    if let artistName { song.primaryArtist = artistName }
                    if let songwriterName { song.primarySongwriter = songwriterName }
                    if let distributor {
                        song.distributorPreset = distributor.preset.rawValue
                        song.distributorCustomName = distributor.customName
                    }
                }
            }
        }
    }
}
