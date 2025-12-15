import AppIntents

enum SiriAttentionFilter: String, AppEnum {
    case incompleteRegistration
    case missingReleaseDate
    case missingIdentifiers
    case invalidSplits
    case phase

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Attention filter")
    static let caseDisplayRepresentations: [SiriAttentionFilter: DisplayRepresentation] = [
        .incompleteRegistration: "Incomplete registration",
        .missingReleaseDate: "Missing release dates",
        .missingIdentifiers: "Missing recording identifiers",
        .invalidSplits: "Invalid splits",
        .phase: "Production phase"
    ]
}
