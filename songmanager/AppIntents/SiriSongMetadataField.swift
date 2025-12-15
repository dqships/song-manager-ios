import AppIntents

enum SiriSongMetadataField: String, AppEnum {
    case title
    case releaseDate
    case artist
    case songwriter
    case primaryRole
    case distributor
    case isrc
    case iswc
    case upc
    case notes
    case webLink

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Song detail")
    static let caseDisplayRepresentations: [SiriSongMetadataField: DisplayRepresentation] = [
        .title: "Title",
        .releaseDate: "Release date",
        .artist: "Primary artist",
        .songwriter: "Primary songwriter",
        .primaryRole: "Primary artist role",
        .distributor: "Distributor",
        .isrc: "ISRC",
        .iswc: "ISWC",
        .upc: "UPC",
        .notes: "Notes",
        .webLink: "Web link"
    ]

    var needsPro: Bool {
        switch self {
        case .releaseDate, .primaryRole, .isrc, .iswc, .upc: true
        default: false
        }
    }

    var needsConfirmation: Bool {
        switch self {
        case .primaryRole, .isrc, .iswc, .upc: true
        default: false
        }
    }

    var confirmationName: String {
        switch self {
        case .primaryRole: "primary artist role"
        case .isrc: "ISRC"
        case .iswc: "ISWC"
        case .upc: "UPC"
        default: rawValue
        }
    }
}
