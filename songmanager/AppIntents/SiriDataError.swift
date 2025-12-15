import Foundation

enum SiriDataError: LocalizedError {
    case songNotFound
    case collaboratorNotFound
    case profileNotFound
    case collaboratorNotOnSong
    case collaboratorAlreadyOnSong
    case invalidSplit
    case splitTotalOverOneHundred
    case freeSongLimitReached
    case freeCollaboratorLimitReached
    case missingCollaboratorName
    case missingSongTitle
    case proAccessRequired
    case noUpdateFields
    case splitScopeRequired
    case invalidPercentage
    case conflictingCollaborator
    case playbackUnavailable(String)
    case collaboratorRequiredForCredits
    case collaboratorDetailsConflict
    case multipleCollaboratorsFound
    case multipleCollaboratorsNotSupported
    case unsupportedSongDescription
    case requestChangedBeforeSave
    case invalidWebLink
    case songLinkLimitReached
    case songLinkNotFound

    var errorDescription: String? {
        switch self {
        case .songNotFound: "That song could not be found."
        case .collaboratorNotFound: "That collaborator could not be found."
        case .profileNotFound: "Your artist profile could not be found."
        case .collaboratorNotOnSong: "That collaborator is not on this song."
        case .collaboratorAlreadyOnSong: "That collaborator is already on this song."
        case .invalidSplit: "Each split must be between 0 and 100 percent."
        case .splitTotalOverOneHundred: "Those splits would add up to more than 100 percent."
        case .freeSongLimitReached: "You have reached the free plan limit of 100 songs."
        case .freeCollaboratorLimitReached: "You have reached the free plan limit of 3 collaborators."
        case .missingCollaboratorName: "Add an artist name or a songwriter name for the collaborator."
        case .missingSongTitle: "Add a title for the song."
        case .proAccessRequired: "This change needs Pro."
        case .noUpdateFields: "Tell Siri which detail you want to update."
        case .splitScopeRequired: "Say whether the percentage is for master, publishing, or both."
        case .invalidPercentage: "Each split must be a finite number from 0 to 100."
        case .conflictingCollaborator: "Choose an existing collaborator or give details for a new collaborator, not both."
        case .playbackUnavailable(let message): message
        case .collaboratorRequiredForCredits: "Add a collaborator before giving a role or split."
        case .collaboratorDetailsConflict: "Those names conflict with a saved collaborator. Choose the saved collaborator or use different details."
        case .multipleCollaboratorsFound: "More than one collaborator has that exact name. Ask Siri to add the saved collaborator, then choose the right person."
        case .multipleCollaboratorsNotSupported: "Add one collaborator in this request. You can add another collaborator afterward."
        case .unsupportedSongDescription: "The details in that description could not be separated safely. Ask Siri to add a song, then answer the follow-up questions."
        case .requestChangedBeforeSave: "Your catalog changed before the request could be saved. Ask Siri again to review the current details."
        case .invalidWebLink: "Use a web address that starts with HTTP or HTTPS."
        case .songLinkLimitReached: "This song already has five saved links. Remove one in the app before adding another."
        case .songLinkNotFound: "That saved link could not be found for this song."
        }
    }
}
