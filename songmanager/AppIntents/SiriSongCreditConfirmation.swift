import Foundation

enum SiriSongCreditConfirmation {
    static func build(
        title: String,
        phase: SongPhase,
        releaseDate: Date?,
        profileArtistName: String,
        collaboratorArtistName: String?,
        collaboratorSongwriterName: String?,
        createsCollaborator: Bool,
        contribution: Contribution?,
        requestedMasterSplit: Double?,
        requestedPublishingSplit: Double?,
        duplicateTitleExists: Bool
    ) -> String {
        var sentences = ["Create \(title)."]
        let primaryName = profileArtistName.isEmpty ? "your artist profile" : profileArtistName
        sentences.append("Use \(primaryName) as the primary artist.")

        let artistName = SiriOptionalTextNormalizer.normalize(collaboratorArtistName)
        let songwriterName = SiriOptionalTextNormalizer.normalize(collaboratorSongwriterName)
        let collaboratorName = artistName ?? songwriterName
        if let collaboratorName {
            var collaboratorSentence = createsCollaborator ? "Add \(collaboratorName)" : "Use saved collaborator \(collaboratorName)"
            if let songwriterName, songwriterName.caseInsensitiveCompare(collaboratorName) != .orderedSame {
                collaboratorSentence += ", songwriter name \(songwriterName)"
            }
            if let contribution { collaboratorSentence += " as \(contribution.displayName)" }
            sentences.append(collaboratorSentence + ".")

            let master = requestedMasterSplit ?? 0
            let publishing = requestedPublishingSplit ?? 0
            let collaboratorMaster = SiriPercentageFormatter.string(from: master)
            let collaboratorPublishing = SiriPercentageFormatter.string(from: publishing)
            let primaryMaster = SiriPercentageFormatter.string(from: 100 - master)
            let primaryPublishing = SiriPercentageFormatter.string(from: 100 - publishing)
            sentences.append("\(collaboratorName) gets \(collaboratorMaster)% of the master and \(collaboratorPublishing)% of publishing.")
            sentences.append("\(primaryName) keeps \(primaryMaster)% of the master and \(primaryPublishing)% of publishing.")
        }

        if phase != .pending { sentences.append("Set the phase to \(phase.rawValue).") }
        if let releaseDate { sentences.append("Set the release date to \(releaseDate.formatted(date: .abbreviated, time: .omitted)).") }
        if duplicateTitleExists { sentences.append("A song with this title already exists, so this will create another one.") }
        sentences.append("Create this song?")
        return sentences.joined(separator: " ")
    }
}
