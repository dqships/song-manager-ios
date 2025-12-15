import Foundation

enum SiriCatalogSummaryFormatter {
    static func format(songs: [Song]) -> String {
        guard !songs.isEmpty else { return "Your catalog has no songs yet." }
        let names = songs.prefix(3).map(\.title).joined(separator: ", ")
        return "Your catalog has \(songs.count) songs. The first \(min(3, songs.count)) are \(names)."
    }
}
