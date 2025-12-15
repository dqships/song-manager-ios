import Foundation

enum SiriRoleChangeConfirmationFormatter {
    nonisolated static func format(
        change: SiriRoleChange,
        collaboratorName: String,
        roleName: String,
        songTitle: String?
    ) -> String {
        let location = songTitle.map { " on \($0)" } ?? " in their default roles"
        switch change {
        case .add:
            return "Add \(roleName) for \(collaboratorName)\(location)?"
        case .remove:
            return "Remove \(roleName) for \(collaboratorName)\(location)?"
        case .replace:
            return "Replace \(collaboratorName)'s roles\(songTitle.map { " on \($0)" } ?? "") with \(roleName)?"
        }
    }
}
