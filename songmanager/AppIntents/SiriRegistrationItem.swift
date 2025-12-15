import AppIntents

enum SiriRegistrationItem: String, AppEnum {
    case pro, mlc, hfa, soundExchange, musicReports, distributor

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Registration item")
    static let caseDisplayRepresentations: [SiriRegistrationItem: DisplayRepresentation] = [
        .pro: "PRO registration", .mlc: "MLC registration", .hfa: "HFA registration", .soundExchange: "SoundExchange registration", .musicReports: "Music Reports registration", .distributor: "Distributor submission"
    ]

    var dialogName: String {
        switch self {
        case .pro: "PRO registration"
        case .mlc: "MLC registration"
        case .hfa: "HFA registration"
        case .soundExchange: "SoundExchange registration"
        case .musicReports: "Music Reports registration"
        case .distributor: "distributor submission"
        }
    }
}
