import AppIntents
import Foundation

struct SongAppEntityQuery: EntityQuery, EntityStringQuery {
    func entities(for identifiers: [SongAppEntity.ID]) async throws -> [SongAppEntity] {
        await MainActor.run {
            let songsByID = Dictionary(uniqueKeysWithValues: AppStateViewModel.live().songs.map { ($0.id, $0) })
            return identifiers.compactMap { songsByID[$0].map(SongAppEntity.init(song:)) }
        }
    }

    func entities(matching string: String) async throws -> [SongAppEntity] {
        await MainActor.run {
            let searchTerm = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return AppStateViewModel.live().songs
                .filter { $0.title.localizedCaseInsensitiveContains(searchTerm) }
                .sorted { lhs, rhs in
                    let lhsExact = lhs.title.compare(searchTerm, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                    let rhsExact = rhs.title.compare(searchTerm, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                    return lhsExact == rhsExact ? lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending : lhsExact
                }
                .map(SongAppEntity.init(song:))
        }
    }

    func suggestedEntities() async throws -> [SongAppEntity] {
        await MainActor.run { AppStateViewModel.live().songs.prefix(20).map(SongAppEntity.init(song:)) }
    }
}
