import AppIntents

enum SiriSplitScope: String, AppEnum {
    case master
    case publishing
    case both

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Split type")
    static let caseDisplayRepresentations: [SiriSplitScope: DisplayRepresentation] = [
        .master: "Master",
        .publishing: "Publishing",
        .both: "Both"
    ]

    var dialogName: String {
        switch self {
        case .master: "master"
        case .publishing: "publishing"
        case .both: "master and publishing"
        }
    }
}
