import AppIntents

struct UpdateArtistProfileIntent: AppIntent {
    static let title: LocalizedStringResource = "Update Artist Profile"
    static let description = IntentDescription("Change one saved artist-profile detail.")
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }

    @Parameter(title: "Detail", requestValueDialog: "Which profile detail should I change?") var field: SiriArtistProfileField
    @Parameter(title: "Text value", requestValueDialog: "What should I save?") var textValue: String?
    @Parameter(title: "Performance rights organization", requestValueDialog: "Which performance rights organization?") var proValue: SiriPRO?
    @Parameter(title: "Distributor", requestValueDialog: "Which distributor?") var distributorValue: SiriDistributor?
    @Parameter(title: "Other distributor name") var otherDistributorName: String?
    @Parameter(title: "Default role", requestValueDialog: "What default role should I save?") var contributionValue: SiriContribution?

    static var parameterSummary: some ParameterSummary {
        Summary("Update artist profile \(\.$field)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        if field == .defaultRole, !(await SiriSubscriptionAccess.hasProAccess()) {
            throw SiriDataError.proAccessRequired
        }
        var artistName: String?
        var songwriterName: String?
        var pro: PRO?
        var distributor: Distributor?
        var ipi: String?
        var defaultContribution: Contribution?
        var confirmationValue = "this value"

        switch field {
        case .artistName:
            artistName = try requiredTextValue("What artist name should I save?")
            confirmationValue = artistName ?? confirmationValue
        case .songwriterName:
            songwriterName = try requiredTextValue("What songwriter name should I save?")
            confirmationValue = songwriterName ?? confirmationValue
        case .pro:
            guard let proValue else { throw $proValue.needsValueError("Which performance rights organization?") }
            pro = proValue.pro
            confirmationValue = proValue.rawValue.uppercased()
        case .distributor:
            guard let distributorValue else { throw $distributorValue.needsValueError("Which distributor?") }
            if distributorValue == .other, SiriOptionalTextNormalizer.normalize(otherDistributorName) == nil {
                throw $otherDistributorName.needsValueError("What is the distributor called?")
            }
            distributor = Distributor(preset: distributorValue.preset, customName: SiriOptionalTextNormalizer.normalize(otherDistributorName))
            confirmationValue = distributorValue == .other
                ? SiriOptionalTextNormalizer.normalize(otherDistributorName) ?? "Other"
                : distributorValue.dialogName
        case .ipi:
            ipi = try requiredTextValue("What IPI number should I save?")
            confirmationValue = ipi ?? confirmationValue
        case .defaultRole:
            guard let contributionValue else { throw $contributionValue.needsValueError("What default role should I save?") }
            defaultContribution = contributionValue.contribution
            confirmationValue = contributionValue.dialogName
        }

        let propagation = field == .artistName || field == .songwriterName || field == .distributor
        let question = propagation
            ? "Save \(confirmationValue) and apply it to your saved songs?"
            : "Save \(confirmationValue) to your artist profile?"
        let confirmation: IntentDialog = "\(question)"
        try await requestConfirmation(result: .result(dialog: confirmation))

        let updateArtistName = artistName
        let updateSongwriterName = songwriterName
        let updatePRO = pro
        let updateDistributor = distributor
        let updateIPI = ipi
        let updateDefaultContribution = defaultContribution
        try await MainActor.run {
            try AppStateViewModel.live().updateProfileForSiri(
                artistName: updateArtistName,
                songwriterName: updateSongwriterName,
                mainPRO: updatePRO,
                distributor: updateDistributor,
                ipi: updateIPI,
                defaultContribution: updateDefaultContribution
            )
        }
        return .result(dialog: "Updated your artist profile. Anything else?")
    }

    private func requiredTextValue(_ prompt: IntentDialog) throws -> String {
        guard let value = SiriOptionalTextNormalizer.normalize(textValue) else {
            throw $textValue.needsValueError(prompt)
        }
        return value
    }
}
