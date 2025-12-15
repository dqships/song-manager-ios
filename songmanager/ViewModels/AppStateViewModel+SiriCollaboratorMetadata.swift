import Foundation

extension AppStateViewModel {
    func updateCollaboratorMetadataForSiri(
        id: UUID,
        artistName: String?,
        songwriterName: String?,
        preferredPRO: PRO?,
        ipi: String?,
        defaultContribution: Contribution?
    ) throws {
        let entity = try fetchCollaboratorForSiri(by: id)
        try performSiriMutation {
            if let artistName = SiriOptionalTextNormalizer.normalize(artistName) { entity.artistName = artistName }
            if let songwriterName = SiriOptionalTextNormalizer.normalize(songwriterName) { entity.songwriterName = songwriterName }
            if let preferredPRO { entity.preferredPRO = preferredPRO.rawValue }
            if let ipi = SiriOptionalTextNormalizer.normalize(ipi) { entity.ipi = ipi }
            if let defaultContribution { entity.defaultContributionsRaw = Self.encodeContributions([defaultContribution]) }
        }
    }
}
