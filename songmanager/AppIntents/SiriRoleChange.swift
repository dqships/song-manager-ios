import AppIntents

enum SiriRoleChange: String, AppEnum {
    case add
    case remove
    case replace

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Role change")
    static let caseDisplayRepresentations: [SiriRoleChange: DisplayRepresentation] = [
        .add: "Add",
        .remove: "Remove",
        .replace: "Replace"
    ]
}
