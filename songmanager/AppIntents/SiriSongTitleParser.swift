import Foundation

enum SiriSongTitleParser {
    nonisolated static func parse(_ request: String) throws -> String {
        if let quotedTitle = SiriRegexFirstCapture.value(
            pattern: #"(?i)^\s*(?:please\s+)?(?:add|create)\s+(?:(?:a|this)\s+)?(?:song\s+)?(?:called|titled|named)\s+[\"“]([^\"”]+)[\"”]"#,
            text: request,
            group: 1
        ) {
            let title = quotedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { throw SiriDataError.missingSongTitle }
            return title
        }

        let prefixPattern = #"(?i)^\s*(?:please\s+)?(?:add|create)\s+(?:(?:a|this)\s+)?(?:song\s+)?(?:(?:called|titled|named)\s+)?"#
        let prefixExpression = try? NSRegularExpression(pattern: prefixPattern)
        let fullRange = NSRange(request.startIndex..<request.endIndex, in: request)
        let withoutPrefix: String
        if let match = prefixExpression?.firstMatch(in: request, range: fullRange),
           let range = Range(match.range, in: request) {
            withoutPrefix = String(request[range.upperBound...])
        } else {
            withoutPrefix = request
        }

        let lowercased = withoutPrefix.lowercased()
        let boundaries = [
            " as a song",
            " featuring ",
            " feature ",
            " co-written with ",
            " written with ",
            " written by ",
            " produced by ",
            " mixed by ",
            " mastered by ",
            " recorded by ",
            " with my collaborator ",
            " with my buddy ",
            " with my friend ",
            " with collaborator ",
            " with ",
            " and move it to ",
            " and move the song to ",
            " in the pending phase",
            " in the writing phase",
            " in the recording phase",
            " in the mixing phase",
            " in the mastering phase",
            " in the completed phase",
            " in pending",
            " in writing",
            " in recording",
            " in mixing",
            " in mastering",
            " in completed"
        ]
        let endIndex = boundaries.compactMap { lowercased.range(of: $0)?.lowerBound }.min() ?? lowercased.endIndex
        let boundaryOffset = lowercased.distance(from: lowercased.startIndex, to: endIndex)
        let originalEnd = withoutPrefix.index(withoutPrefix.startIndex, offsetBy: boundaryOffset)
        let title = withoutPrefix[..<originalEnd]
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))

        guard !title.isEmpty else { throw SiriDataError.missingSongTitle }
        return title
    }
}
