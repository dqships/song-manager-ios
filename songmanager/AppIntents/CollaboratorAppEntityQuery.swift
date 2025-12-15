import AppIntents
import Foundation

struct CollaboratorAppEntityQuery: EntityQuery, EntityStringQuery {
    func entities(for identifiers: [CollaboratorAppEntity.ID]) async throws -> [CollaboratorAppEntity] {
        await MainActor.run {
            let collaboratorsByID = Dictionary(uniqueKeysWithValues: AppStateViewModel.live().collaborators.map { ($0.id, $0) })
            return identifiers.compactMap { collaboratorsByID[$0].map(CollaboratorAppEntity.init(collaborator:)) }
        }
    }

    func entities(matching string: String) async throws -> [CollaboratorAppEntity] {
        await MainActor.run {
            let searchTerm = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return AppStateViewModel.live().collaborators
                .filter { $0.artistName.localizedCaseInsensitiveContains(searchTerm) || $0.songwriterName.localizedCaseInsensitiveContains(searchTerm) }
                .sorted { lhs, rhs in
                    let lhsExact = [lhs.artistName, lhs.songwriterName].contains {
                        $0.compare(searchTerm, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                    }
                    let rhsExact = [rhs.artistName, rhs.songwriterName].contains {
                        $0.compare(searchTerm, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                    }
                    let lhsName = lhs.artistName.isEmpty ? lhs.songwriterName : lhs.artistName
                    let rhsName = rhs.artistName.isEmpty ? rhs.songwriterName : rhs.artistName
                    return lhsExact == rhsExact ? lhsName.localizedCaseInsensitiveCompare(rhsName) == .orderedAscending : lhsExact
                }
                .map(CollaboratorAppEntity.init(collaborator:))
        }
    }

    func suggestedEntities() async throws -> [CollaboratorAppEntity] {
        await MainActor.run { AppStateViewModel.live().collaborators.prefix(20).map(CollaboratorAppEntity.init(collaborator:)) }
    }
}
