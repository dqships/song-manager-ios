import Foundation

enum SiriCollaboratorClauseParser {
    nonisolated static func parse(_ request: String) throws -> SiriParsedCollaborator? {
        let roleMarkers = [
            " co-written with ",
            " written with ",
            " written by ",
            " produced by ",
            " mixed by ",
            " mastered by ",
            " recorded by ",
            " featuring ",
            " feature "
        ]
        let genericMarkers = [
            " with my collaborator ",
            " with my buddy ",
            " with my friend ",
            " with collaborator ",
            " with "
        ]

        let marker = roleMarkers.first(where: { request.range(of: $0, options: .caseInsensitive) != nil })
            ?? genericMarkers.first(where: { request.range(of: $0, options: .caseInsensitive) != nil })
        guard let marker,
              let markerRange = request.range(of: marker, options: .caseInsensitive) else {
            return nil
        }

        var clause = String(request[markerRange.upperBound...])
        if marker == " with " && clause.lowercased().hasPrefix("me as") {
            return nil
        }

        let splitBoundaryPattern = #"(?i)\s+(?:(?:and\s+)?(?:give(?:\s+(?:him|her|them))?|(?:he|she|they)\s+gets?|who\s+gets?|gets?|at)\s+-?\d|and\s+move\s+(?:it|the\s+song)\s+to\s+|in\s+(?:the\s+)?(?:pending|writing|recording|mixing|mastering|completed)(?:\s+phase)?\b)"#
        if let expression = try? NSRegularExpression(pattern: splitBoundaryPattern),
           let match = expression.firstMatch(in: clause, range: NSRange(clause.startIndex..<clause.endIndex, in: clause)),
           let boundary = Range(match.range, in: clause) {
            clause = String(clause[..<boundary.lowerBound])
        }

        clause = clause
            .replacingOccurrences(of: "my buddy ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "my friend ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "my collaborator ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "collaborator ", with: "", options: [.caseInsensitive, .anchored])
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))

        guard !clause.isEmpty else { throw SiriDataError.missingCollaboratorName }

        if let songwriter = SiriRegexFirstCapture.value(
            pattern: #"(?i)^(.+?)\s+who\s+goes\s+by\s+(.+)$"#,
            text: clause,
            group: 1
        ), let artist = SiriRegexFirstCapture.value(
            pattern: #"(?i)^(.+?)\s+who\s+goes\s+by\s+(.+)$"#,
            text: clause,
            group: 2
        ) {
            return SiriParsedCollaborator(
                artistName: artist.trimmingCharacters(in: .whitespacesAndNewlines),
                songwriterName: songwriter.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        if let artist = SiriRegexFirstCapture.value(
            pattern: #"(?i)^(.+?),?\s+(?:whose\s+)?legal\s+name\s+(?:is\s+)?(.+)$"#,
            text: clause,
            group: 1
        ), let songwriter = SiriRegexFirstCapture.value(
            pattern: #"(?i)^(.+?),?\s+(?:whose\s+)?legal\s+name\s+(?:is\s+)?(.+)$"#,
            text: clause,
            group: 2
        ) {
            return SiriParsedCollaborator(
                artistName: artist.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)),
                songwriterName: songwriter.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            )
        }

        if SiriRegexFirstCapture.value(pattern: #"(?i)\b(?:and|plus)\b"#, text: clause, group: 0) != nil {
            throw SiriDataError.multipleCollaboratorsNotSupported
        }

        let name = clause.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
        let ambiguousPronouns: Set<String> = ["her", "him", "it", "me", "myself", "them", "us", "you", "yourself"]
        guard !ambiguousPronouns.contains(name.lowercased()) else {
            throw SiriDataError.unsupportedSongDescription
        }
        let lowercasedMarker = marker.lowercased()
        if lowercasedMarker.contains("written") {
            return SiriParsedCollaborator(artistName: nil, songwriterName: name)
        }
        return SiriParsedCollaborator(artistName: name, songwriterName: nil)
    }
}
