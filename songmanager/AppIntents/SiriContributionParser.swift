import Foundation

enum SiriContributionParser {
    nonisolated static func parse(_ request: String) -> Contribution? {
        let lowercased = request.lowercased()
        if lowercased.contains("featuring ") || lowercased.contains(" feature ") { return .featuredArtist }
        if lowercased.contains("co-written with ") || lowercased.contains("written with ") || lowercased.contains("written by ") { return .songwriter }
        if lowercased.contains("produced by ") { return .producer }
        if lowercased.contains("mixed by ") { return .mixingEngineer }
        if lowercased.contains("mastered by ") { return .masteringEngineer }
        if lowercased.contains("recorded by ") { return .recordingEngineer }
        return nil
    }
}
