import AppIntents

enum SiriProtectedCatalogAction: String, AppEnum {
    case deleteSong
    case deleteCollaborator
    case clearSongInformation
    case clearCollaboratorInformation

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Protected catalog action")
    static let caseDisplayRepresentations: [SiriProtectedCatalogAction: DisplayRepresentation] = [
        .deleteSong: "Delete a song",
        .deleteCollaborator: "Delete a collaborator",
        .clearSongInformation: "Clear song information",
        .clearCollaboratorInformation: "Clear collaborator information"
    ]
}
