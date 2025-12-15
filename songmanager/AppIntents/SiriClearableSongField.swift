import AppIntents

enum SiriClearableSongField: String, AppEnum {
    case releaseDate
    case notes
    case isrc
    case iswc
    case upc
    case musicLibraryLink
    case savedWebLink
    case registrationChecklist
    case collaboratorSplits

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Song information")
    static let caseDisplayRepresentations: [SiriClearableSongField: DisplayRepresentation] = [
        .releaseDate: "Release date",
        .notes: "Notes",
        .isrc: "ISRC",
        .iswc: "ISWC",
        .upc: "UPC",
        .musicLibraryLink: "Music library link",
        .savedWebLink: "Saved web link",
        .registrationChecklist: "Registration checklist",
        .collaboratorSplits: "Collaborator splits"
    ]

    var dialogName: String {
        switch self {
        case .releaseDate: "the release date"
        case .notes: "the notes"
        case .isrc: "the ISRC"
        case .iswc: "the ISWC"
        case .upc: "the UPC"
        case .musicLibraryLink: "the Music library link"
        case .savedWebLink: "the saved web link"
        case .registrationChecklist: "the registration checklist"
        case .collaboratorSplits: "the collaborator splits"
        }
    }
}
