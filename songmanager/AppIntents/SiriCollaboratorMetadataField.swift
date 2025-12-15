import AppIntents

enum SiriCollaboratorMetadataField: String, AppEnum {
    case artistName
    case songwriterName
    case pro
    case ipi
    case defaultRole
    case roleOnSong

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Collaborator detail")
    static let caseDisplayRepresentations: [SiriCollaboratorMetadataField: DisplayRepresentation] = [
        .artistName: "Artist name",
        .songwriterName: "Songwriter name",
        .pro: "Performance rights organization",
        .ipi: "IPI number",
        .defaultRole: "Default role",
        .roleOnSong: "Role on a song"
    ]
}
