import Foundation

enum SiriSongDescriptionParser {
    nonisolated static func parse(_ request: String) throws -> SiriParsedSongDescription {
        try SiriSongDescriptionSyntaxValidator.validate(request)
        let title = try SiriSongTitleParser.parse(request)
        let detailText = SiriSongDescriptionDetailText.extract(from: request)
        let collaborator = try SiriCollaboratorClauseParser.parse(detailText)
        let contribution = SiriContributionParser.parse(detailText)
        let splits = try SiriSplitClauseParser.parse(detailText)

        if (contribution != nil || splits.master != nil || splits.publishing != nil || splits.ambiguous != nil), collaborator == nil {
            throw SiriDataError.collaboratorRequiredForCredits
        }

        return SiriParsedSongDescription(
            title: title,
            phase: SiriSongPhaseParser.parse(detailText),
            collaborator: collaborator,
            contribution: contribution,
            splits: splits
        )
    }
}
