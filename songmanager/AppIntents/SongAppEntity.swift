import AppIntents
import Foundation

struct SongAppEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Song")
    static let defaultQuery = SongAppEntityQuery()

    let id: UUID
    let title: String
    let phase: String

    init(song: Song) {
        id = song.id
        title = song.title
        phase = song.phase.rawValue
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(phase)")
    }
}
