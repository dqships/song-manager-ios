import Foundation

enum SiriCollaboratorSummaryFormatter {
    static func format(_ collaborator: Collaborator, songs: [Song]) -> String {
        let name = collaborator.artistName.isEmpty ? collaborator.songwriterName : collaborator.artistName
        let creditCount = songs.filter { song in song.collaborators.contains(where: { $0.id == collaborator.id }) }.count
        let pro = collaborator.preferredPRO?.rawValue ?? "no saved performance rights organization"
        let roles = collaborator.defaultContributions.map(\.displayName).sorted().joined(separator: ", ")
        let roleText = roles.isEmpty ? "no default roles" : roles
        return "\(name) is credited on \(creditCount) song\(creditCount == 1 ? "" : "s"), with \(pro) and \(roleText)."
    }
}
