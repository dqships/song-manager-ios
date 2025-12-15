import Foundation

enum SiriReadinessFormatter {
    static func format(_ song: Song) -> String {
        var needs: [String] = []
        if song.primaryArtist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { needs.append("a primary artist") }
        if song.primarySongwriter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { needs.append("a primary songwriter") }
        if song.releaseDate == nil { needs.append("a release date") }
        if song.checklist.completedCount < song.checklist.total { needs.append("\(song.checklist.total - song.checklist.completedCount) registration items") }
        if !SiriSongSplitValidator.isValid(song) { needs.append("corrected splits") }
        if song.isrc?.isEmpty != false { needs.append("an ISRC") }
        if song.iswc?.isEmpty != false { needs.append("an ISWC") }
        if song.upc?.isEmpty != false { needs.append("a UPC") }
        guard !needs.isEmpty else { return "\(song.title) has all tracked release details complete." }
        return "\(song.title) still needs \(needs.prefix(4).joined(separator: ", "))\(needs.count > 4 ? ", and \(needs.count - 4) more items" : "")."
    }
}
