import Foundation

struct SiriParsedSplits: Equatable {
    let master: Double?
    let publishing: Double?
    let ambiguous: Double?

    nonisolated static let empty = SiriParsedSplits(master: nil, publishing: nil, ambiguous: nil)
}
