import Foundation

enum SiriSongDescriptionSyntaxValidator {
    nonisolated static func validate(_ request: String) throws {
        let lowercased = request.lowercased()
        let hasQuotedTitle = SiriRegexFirstCapture.value(
            pattern: #"(?i)^\s*(?:please\s+)?(?:add|create)\s+(?:(?:a|this)\s+)?(?:song\s+)?(?:called|titled|named)\s+[\"“][^\"”]+[\"”]"#,
            text: request,
            group: 0
        ) != nil
        if hasQuotedTitle || lowercased.contains(" as a song") {
            return
        }

        let ambiguousMarkers = [
            " co-written with ",
            " written with ",
            " written by ",
            " produced by ",
            " mixed by ",
            " mastered by ",
            " recorded by ",
            " featuring ",
            " feature ",
            " with my collaborator ",
            " with my buddy ",
            " with my friend ",
            " with collaborator ",
            " with ",
            " and move it to ",
            " and move the song to ",
            " in pending",
            " in writing",
            " in recording",
            " in mixing",
            " in mastering",
            " in completed"
        ]
        guard !ambiguousMarkers.contains(where: lowercased.contains) else {
            throw SiriDataError.unsupportedSongDescription
        }
    }
}
