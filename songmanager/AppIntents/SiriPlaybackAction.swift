import AppIntents

enum SiriPlaybackAction: String, AppEnum {
    case play, pause, resume

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Playback action")
    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [.play: "Play", .pause: "Pause", .resume: "Resume"]
}
