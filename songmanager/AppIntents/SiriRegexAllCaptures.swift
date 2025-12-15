import Foundation

enum SiriRegexAllCaptures {
    nonisolated static func values(pattern: String, text: String, group: Int = 1) -> [String] {
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return expression.matches(in: text, range: range).compactMap { match in
            guard group < match.numberOfRanges,
                  let captureRange = Range(match.range(at: group), in: text) else {
                return nil
            }
            return String(text[captureRange])
        }
    }
}
