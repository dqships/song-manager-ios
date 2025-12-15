import Foundation

enum SiriSongSummaryFormatter {
    static func format(_ song: Song) -> String {
        let collaborators = song.collaborators.count
        let master = SiriPercentageFormatter.string(from: song.primarySplits.master)
        let publishing = SiriPercentageFormatter.string(from: song.primarySplits.publishing)
        return "\(song.title) is in \(song.phase.rawValue). It has \(collaborators) collaborator\(collaborators == 1 ? "" : "s") and \(song.checklist.completedCount) of 6 registration items complete. Your current shares are \(master) percent master and \(publishing) percent publishing."
    }
}
