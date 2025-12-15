import Foundation

enum SiriSongPhaseParser {
    nonisolated static func parse(_ request: String) -> SongPhase {
        let pattern = #"(?i)\b(?:move(?:\s+(?:it|the\s+song))?\s+to|phase(?:\s+is)?|in(?:\s+the)?)(?:\s+)(pending|writing|recording|mixing|mastering|completed)(?:\s+phase)?\b"#
        guard let value = SiriRegexFirstCapture.value(pattern: pattern, text: request)?.lowercased() else {
            return .pending
        }
        return SongPhase(rawValue: value.capitalized) ?? .pending
    }
}
