import Foundation

struct SiriSongCreditPlan: Equatable {
    let request: SiriCreateSongWithCreditsRequest
    let title: String
    let collaboratorID: UUID?
    let collaboratorArtistName: String?
    let collaboratorSongwriterName: String?
    let createsCollaborator: Bool
    let duplicateTitleExists: Bool
    let masterSplit: Double
    let publishingSplit: Double
    let profileArtistName: String
    let profileSongwriterName: String
    let profileDistributor: Distributor
    let primaryContributions: Set<Contribution>
    let collaboratorContributions: Set<Contribution>
    let confirmation: String
}
