import Foundation

enum SiriRegexFirstCapture {
    nonisolated static func value(pattern: String, text: String, group: Int = 1) -> String? {
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = expression.firstMatch(in: text, range: range),
              group < match.numberOfRanges,
              let captureRange = Range(match.range(at: group), in: text) else {
            return nil
        }
        return String(text[captureRange])
    }
}
