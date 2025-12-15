import AppIntents

enum SiriAssistantWorkflow: String, AppEnum {
    case describeSong
    case attachSavedCollaborator
    case reviewCatalog
    case checkReleaseReadiness
    case summarizeSong
    case summarizeCollaborator
    case findSongsNeedingAttention
    case playImportedSong
    case pausePlayback
    case resumePlayback

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "ReleaseKit action")
    static let caseDisplayRepresentations: [SiriAssistantWorkflow: DisplayRepresentation] = [
        .describeSong: "Describe a song",
        .attachSavedCollaborator: "Add a saved collaborator to a song",
        .reviewCatalog: "Review my catalog",
        .checkReleaseReadiness: "Check release readiness",
        .summarizeSong: "Summarize a song",
        .summarizeCollaborator: "Summarize a collaborator",
        .findSongsNeedingAttention: "Find songs needing attention",
        .playImportedSong: "Play an imported song",
        .pausePlayback: "Pause song playback",
        .resumePlayback: "Resume song playback"
    ]
}
