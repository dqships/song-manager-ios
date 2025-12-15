import Foundation

struct SiriCreateSongWithCreditsRequest: Equatable {
    let title: String
    let phase: SongPhase
    let releaseDate: Date?
    let existingCollaboratorID: UUID?
    let collaboratorArtistName: String?
    let collaboratorSongwriterName: String?
    let collaboratorPRO: PRO?
    let collaboratorIPI: String?
    let contributions: Set<Contribution>
    let masterSplit: Double?
    let publishingSplit: Double?
}
