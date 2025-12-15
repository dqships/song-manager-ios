import Foundation

enum SiriSplitClauseParser {
    nonisolated static func parse(_ request: String) throws -> SiriParsedSplits {
        let number = #"(-?\d+(?:\.\d+)?)"#
        let percent = #"\s*(?:%|percent)"#
        let optionalOf = #"\s*(?:of\s+(?:the\s+)?)?"#
        let masterWords = #"(?:master|record(?:ing)?)"#
        let publishingWords = #"(?:publishing|composition|songwriting)"#

        let masterAfterAmount = "(?i)" + number + percent + optionalOf + masterWords + #"\b"#
        let masterBeforeAmount = "(?i)\\b" + masterWords + #"(?:\s+split)?\s*(?:is|at|of)?\s*"# + number + percent
        let publishingAfterAmount = "(?i)" + number + percent + optionalOf + publishingWords + #"\b"#
        let publishingBeforeAmount = "(?i)\\b" + publishingWords + #"(?:\s+split)?\s*(?:is|at|of)?\s*"# + number + percent
        let bothAfterAmount = "(?i)" + number + percent + #"\s*(?:of\s+)?(?:both|each)\b"#
        let masterAndPublishing = "(?i)" + number + percent + optionalOf + masterWords + #"\s+and\s+"# + publishingWords + #"\b"#

        let master = SiriRegexFirstCapture.value(pattern: masterAfterAmount, text: request).flatMap(Double.init)
            ?? SiriRegexFirstCapture.value(pattern: masterBeforeAmount, text: request).flatMap(Double.init)
        let publishing = SiriRegexFirstCapture.value(pattern: publishingAfterAmount, text: request).flatMap(Double.init)
            ?? SiriRegexFirstCapture.value(pattern: publishingBeforeAmount, text: request).flatMap(Double.init)
        let both = SiriRegexFirstCapture.value(pattern: bothAfterAmount, text: request).flatMap(Double.init)
            ?? SiriRegexFirstCapture.value(pattern: masterAndPublishing, text: request).flatMap(Double.init)

        if let both {
            return SiriParsedSplits(master: both, publishing: both, ambiguous: nil)
        }
        if master != nil || publishing != nil {
            return SiriParsedSplits(master: master, publishing: publishing, ambiguous: nil)
        }

        let percentages = SiriRegexAllCaptures.values(
            pattern: #"(?i)(-?\d+(?:\.\d+)?)\s*(?:%|percent)\b"#,
            text: request
        ).compactMap(Double.init)
        if percentages.count > 1 { throw SiriDataError.unsupportedSongDescription }
        if let percentage = percentages.first {
            return SiriParsedSplits(master: nil, publishing: nil, ambiguous: percentage)
        }
        return .empty
    }
}
