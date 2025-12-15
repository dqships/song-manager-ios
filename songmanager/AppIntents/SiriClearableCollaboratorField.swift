import AppIntents

enum SiriClearableCollaboratorField: String, AppEnum {
    case songwriterName
    case pro
    case ipi
    case defaultRoles
    case rolesOnSong

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Collaborator information")
    static let caseDisplayRepresentations: [SiriClearableCollaboratorField: DisplayRepresentation] = [
        .songwriterName: "Songwriter name",
        .pro: "Performance rights organization",
        .ipi: "IPI number",
        .defaultRoles: "Default roles",
        .rolesOnSong: "Roles on a song"
    ]

    var dialogName: String {
        switch self {
        case .songwriterName: "the songwriter name"
        case .pro: "the performance rights organization"
        case .ipi: "the IPI number"
        case .defaultRoles: "the default roles"
        case .rolesOnSong: "the roles on that song"
        }
    }
}
