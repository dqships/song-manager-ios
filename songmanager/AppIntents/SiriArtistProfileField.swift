import AppIntents

enum SiriArtistProfileField: String, AppEnum {
    case artistName
    case songwriterName
    case pro
    case distributor
    case ipi
    case defaultRole

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Profile detail")
    static let caseDisplayRepresentations: [SiriArtistProfileField: DisplayRepresentation] = [
        .artistName: "Artist name",
        .songwriterName: "Songwriter name",
        .pro: "Performance rights organization",
        .distributor: "Distributor",
        .ipi: "IPI number",
        .defaultRole: "Default song role"
    ]
}
