import AppIntents

enum SiriSongLinkAction: String, AppEnum {
    case add
    case update
    case remove

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Link action")
    static let caseDisplayRepresentations: [SiriSongLinkAction: DisplayRepresentation] = [
        .add: "Add",
        .update: "Update",
        .remove: "Remove"
    ]
}
