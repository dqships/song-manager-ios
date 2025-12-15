import Foundation

enum SiriSongDescriptionDetailText {
    nonisolated static func extract(from request: String) -> String {
        let pattern = #"(?i)^\s*(?:please\s+)?(?:add|create)\s+(?:(?:a|this)\s+)?(?:song\s+)?(?:called|titled|named)\s+[\"“][^\"”]+[\"”]"#
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(
                in: request,
                range: NSRange(request.startIndex..<request.endIndex, in: request)
              ),
              let range = Range(match.range, in: request) else {
            return request
        }
        return String(request[range.upperBound...])
    }
}
