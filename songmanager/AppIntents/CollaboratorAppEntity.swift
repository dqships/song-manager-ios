import AppIntents
import Foundation

struct CollaboratorAppEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Collaborator")
    static let defaultQuery = CollaboratorAppEntityQuery()

    let id: UUID
    let artistName: String
    let songwriterName: String

    init(collaborator: Collaborator) {
        id = collaborator.id
        artistName = collaborator.artistName
        songwriterName = collaborator.songwriterName
    }

    var displayRepresentation: DisplayRepresentation {
        let name = artistName.isEmpty ? songwriterName : artistName
        let detail = artistName.isEmpty || songwriterName.isEmpty || artistName == songwriterName ? nil : songwriterName
        return DisplayRepresentation(title: "\(name)", subtitle: detail.map { "\($0)" })
    }
}
