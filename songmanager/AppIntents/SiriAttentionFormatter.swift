import Foundation

enum SiriAttentionFormatter {
    static func format(songs: [Song], filter: SiriAttentionFilter, phase: SongPhase?) -> String {
        let matches: [Song]
        switch filter {
        case .incompleteRegistration:
            matches = songs.filter { $0.checklist.completedCount < $0.checklist.total }
        case .missingReleaseDate:
            matches = songs.filter { $0.releaseDate == nil }
        case .missingIdentifiers:
            matches = songs.filter { $0.isrc?.isEmpty != false || $0.iswc?.isEmpty != false || $0.upc?.isEmpty != false }
        case .invalidSplits:
            matches = songs.filter { !SiriSongSplitValidator.isValid($0) }
        case .phase:
            matches = phase.map { selected in songs.filter { $0.phase == selected } } ?? []
        }
        guard !matches.isEmpty else { return "No songs match that check." }
        let names = matches.prefix(3).map(\.title).joined(separator: ", ")
        return "\(matches.count) song\(matches.count == 1 ? "" : "s") match: \(names)."
    }
}
