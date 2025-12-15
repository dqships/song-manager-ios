import Foundation

struct SiriParsedSongDescription: Equatable {
    let title: String
    let phase: SongPhase
    let collaborator: SiriParsedCollaborator?
    let contribution: Contribution?
    let splits: SiriParsedSplits
}
