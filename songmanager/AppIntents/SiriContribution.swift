import AppIntents

enum SiriContribution: String, AppEnum {
    case featuredArtist
    case songwriter
    case producer
    case mixingEngineer
    case masteringEngineer
    case recordingEngineer

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Collaborator role")
    static let caseDisplayRepresentations: [SiriContribution: DisplayRepresentation] = [
        .featuredArtist: "Featured Artist",
        .songwriter: "Songwriter",
        .producer: "Producer",
        .mixingEngineer: "Mixing Engineer",
        .masteringEngineer: "Mastering Engineer",
        .recordingEngineer: "Recording Engineer"
    ]

    var contribution: Contribution {
        switch self {
        case .featuredArtist: .featuredArtist
        case .songwriter: .songwriter
        case .producer: .producer
        case .mixingEngineer: .mixingEngineer
        case .masteringEngineer: .masteringEngineer
        case .recordingEngineer: .recordingEngineer
        }
    }

    nonisolated var dialogName: String {
        switch self {
        case .featuredArtist: "Featured Artist"
        case .songwriter: "Songwriter"
        case .producer: "Producer"
        case .mixingEngineer: "Mixing Engineer"
        case .masteringEngineer: "Mastering Engineer"
        case .recordingEngineer: "Recording Engineer"
        }
    }
}
