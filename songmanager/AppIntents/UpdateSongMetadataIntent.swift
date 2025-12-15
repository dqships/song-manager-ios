import AppIntents

struct UpdateSongMetadataIntent: AppIntent {
    static let title: LocalizedStringResource = "Update Song Details"
    static let description = IntentDescription("Change one saved song detail.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Song", requestValueDialog: "Which song?") var song: SongAppEntity
    @Parameter(title: "Detail", requestValueDialog: "Which song detail should I change?") var field: SiriSongMetadataField
    @Parameter(title: "Text value", requestValueDialog: "What should I save?") var textValue: String?
    @Parameter(title: "Date", requestValueDialog: "What date should I save?") var dateValue: Date?
    @Parameter(title: "Primary artist role", requestValueDialog: "What role should I save for the primary artist?") var contributionValue: SiriContribution?
    @Parameter(title: "Distributor", requestValueDialog: "Which distributor?") var distributorValue: SiriDistributor?
    @Parameter(title: "Other distributor name") var otherDistributorName: String?
    @Parameter(title: "Link address", requestValueDialog: "What is the web address?") var urlValue: URL?
    @Parameter(title: "Link name", requestValueDialog: "What should I call this link?") var linkTitle: String?
    @Parameter(title: "Link action", requestValueDialog: "Should I add, update, or remove the link?") var linkAction: SiriSongLinkAction?

    static var parameterSummary: some ParameterSummary {
        Summary("Update \(\.$field) for \(\.$song)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        if field.needsPro, !(await SiriSubscriptionAccess.hasProAccess()) { throw SiriDataError.proAccessRequired }

        if field.needsConfirmation {
            let value = try confirmationValue()
            try await requestConfirmation(result: .result(dialog: "Set the \(field.confirmationName) for \(song.title) to \(value)?"))
        }

        switch field {
        case .title:
            try await update(title: try requiredTextValue())
        case .releaseDate:
            guard let dateValue else { throw $dateValue.needsValueError("What release date should I save?") }
            try await update(releaseDate: dateValue)
        case .artist:
            try await update(primaryArtist: try requiredTextValue())
        case .songwriter:
            try await update(primarySongwriter: try requiredTextValue())
        case .primaryRole:
            guard let contributionValue else {
                throw $contributionValue.needsValueError("What role should I save for the primary artist?")
            }
            try await MainActor.run {
                try AppStateViewModel.live().updatePrimarySongContributionForSiri(
                    songID: song.id,
                    contribution: contributionValue.contribution
                )
            }
        case .distributor:
            guard let distributorValue else { throw $distributorValue.needsValueError("Which distributor?") }
            if distributorValue == .other, SiriOptionalTextNormalizer.normalize(otherDistributorName) == nil {
                throw $otherDistributorName.needsValueError("What is the distributor called?")
            }
            let distributor = Distributor(preset: distributorValue.preset, customName: SiriOptionalTextNormalizer.normalize(otherDistributorName))
            try await update(distributor: distributor)
        case .isrc:
            try await update(isrc: try requiredTextValue())
        case .iswc:
            try await update(iswc: try requiredTextValue())
        case .upc:
            try await update(upc: try requiredTextValue())
        case .notes:
            try await update(notes: try requiredTextValue())
        case .webLink:
            try await updateLink()
        }

        return .result(dialog: "Updated \(song.title). Anything else?")
    }

    private func updateLink() async throws {
        guard let linkAction else {
            throw $linkAction.needsValueError("Should I add, update, or remove the link?")
        }
        let title = SiriOptionalTextNormalizer.normalize(linkTitle) ?? "Link"
        switch linkAction {
        case .add:
            guard let urlValue else { throw $urlValue.needsValueError("What is the web address?") }
            try await MainActor.run { try AppStateViewModel.live().addSongLinkForSiri(songID: song.id, title: title, url: urlValue) }
        case .update:
            guard let urlValue else { throw $urlValue.needsValueError("What is the new web address?") }
            try await MainActor.run { try AppStateViewModel.live().updateSongLinkForSiri(songID: song.id, title: title, url: urlValue) }
        case .remove:
            try await requestConfirmation(result: .result(dialog: "Remove the link named \(title) from \(song.title)?"))
            try await MainActor.run { try AppStateViewModel.live().removeSongLinkForSiri(songID: song.id, title: title) }
        }
    }

    private func requiredTextValue() throws -> String {
        guard let value = SiriOptionalTextNormalizer.normalize(textValue) else {
            throw $textValue.needsValueError("What should I save?")
        }
        return value
    }

    private func confirmationValue() throws -> String {
        if field == .primaryRole {
            guard let contributionValue else {
                throw $contributionValue.needsValueError("What role should I save for the primary artist?")
            }
            return contributionValue.dialogName
        }
        return try requiredTextValue()
    }

    private func update(
        title: String? = nil,
        releaseDate: Date? = nil,
        primaryArtist: String? = nil,
        primarySongwriter: String? = nil,
        distributor: Distributor? = nil,
        isrc: String? = nil,
        iswc: String? = nil,
        upc: String? = nil,
        notes: String? = nil
    ) async throws {
        try await MainActor.run {
            try AppStateViewModel.live().updateSongMetadataForSiri(
                id: song.id,
                title: title,
                releaseDate: releaseDate,
                primaryArtist: primaryArtist,
                primarySongwriter: primarySongwriter,
                distributor: distributor,
                isrc: isrc,
                iswc: iswc,
                upc: upc,
                notes: notes
            )
        }
    }
}
