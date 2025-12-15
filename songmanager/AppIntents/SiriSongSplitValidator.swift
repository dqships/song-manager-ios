import Foundation

enum SiriSongSplitValidator {
    static func isValid(_ song: Song) -> Bool {
        let master = song.collaboratorSplits.values.reduce(song.primarySplits.master) { $0 + $1.master }
        let publishing = song.collaboratorSplits.values.reduce(song.primarySplits.publishing) { $0 + $1.publishing }
        return abs(master - 100) < 0.001 && abs(publishing - 100) < 0.001
    }
}
