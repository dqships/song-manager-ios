import Foundation

enum SiriAttachAllocationConfirmationFormatter {
    nonisolated static func format(
        collaboratorName: String,
        songTitle: String,
        roleText: String,
        preview: SiriSplitPreview
    ) -> String {
        let roleClause = roleText.isEmpty ? "" : " as \(roleText)"
        let collaboratorMaster = SiriPercentageFormatter.string(from: preview.collaboratorMaster)
        let collaboratorPublishing = SiriPercentageFormatter.string(from: preview.collaboratorPublishing)
        let primaryMaster = SiriPercentageFormatter.string(from: preview.primaryMaster)
        let primaryPublishing = SiriPercentageFormatter.string(from: preview.primaryPublishing)
        return "Add \(collaboratorName) to \(songTitle)\(roleClause). They will have \(collaboratorMaster) percent master and \(collaboratorPublishing) percent publishing. Your remaining shares will be \(primaryMaster) percent master and \(primaryPublishing) percent publishing. Save this change?"
    }
}
