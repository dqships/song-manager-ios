import AppIntents

enum SiriSongPhase: String, AppEnum {
    case pending, writing, recording, mixing, mastering, completed

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Song phase")
    static let caseDisplayRepresentations: [SiriSongPhase: DisplayRepresentation] = [
        .pending: "Pending", .writing: "Writing", .recording: "Recording", .mixing: "Mixing", .mastering: "Mastering", .completed: "Completed"
    ]

    var songPhase: SongPhase { SongPhase(rawValue: rawValue.capitalized) ?? .pending }
}
