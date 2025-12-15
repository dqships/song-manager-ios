import Foundation

extension AppStateViewModel {
    func planSongWithCreditsForSiri(
        request: SiriCreateSongWithCreditsRequest,
        hasProAccess: Bool
    ) throws -> SiriSongCreditPlan {
        let title = request.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw SiriDataError.missingSongTitle }
        guard hasProAccess || songs.count < FreeTierLimits.songs else { throw SiriDataError.freeSongLimitReached }

        for split in [request.masterSplit, request.publishingSplit].compactMap({ $0 }) {
            guard split.isFinite, (0...100).contains(split) else { throw SiriDataError.invalidPercentage }
        }
        if request.releaseDate != nil || !request.contributions.isEmpty || request.masterSplit != nil || request.publishingSplit != nil {
            guard hasProAccess else { throw SiriDataError.proAccessRequired }
        }

        let artistName = SiriOptionalTextNormalizer.normalize(request.collaboratorArtistName)
        let songwriterName = SiriOptionalTextNormalizer.normalize(request.collaboratorSongwriterName)
        let ipi = SiriOptionalTextNormalizer.normalize(request.collaboratorIPI)
        let hasNewDetails = artistName != nil || songwriterName != nil || request.collaboratorPRO != nil || ipi != nil
        if request.existingCollaboratorID != nil && hasNewDetails { throw SiriDataError.conflictingCollaborator }

        var collaboratorID: UUID?
        var resolvedArtistName = artistName
        var resolvedSongwriterName = songwriterName
        var createsCollaborator = false

        if let existingID = request.existingCollaboratorID {
            guard let existing = collaborators.first(where: { $0.id == existingID }) else { throw SiriDataError.collaboratorNotFound }
            collaboratorID = existing.id
            resolvedArtistName = SiriOptionalTextNormalizer.normalize(existing.artistName)
            resolvedSongwriterName = SiriOptionalTextNormalizer.normalize(existing.songwriterName)
        } else if artistName != nil || songwriterName != nil {
            let exactMatches = collaborators.filter { collaborator in
                let artistMatches = artistName.map { SiriNameNormalizer.normalize(collaborator.artistName) == SiriNameNormalizer.normalize($0) } ?? true
                let songwriterMatches = songwriterName.map { SiriNameNormalizer.normalize(collaborator.songwriterName) == SiriNameNormalizer.normalize($0) } ?? true
                return artistMatches && songwriterMatches
            }
            if exactMatches.count > 1 { throw SiriDataError.multipleCollaboratorsFound }
            if let existing = exactMatches.first {
                if request.collaboratorPRO != nil || ipi != nil { throw SiriDataError.collaboratorDetailsConflict }
                collaboratorID = existing.id
                resolvedArtistName = SiriOptionalTextNormalizer.normalize(existing.artistName)
                resolvedSongwriterName = SiriOptionalTextNormalizer.normalize(existing.songwriterName)
            } else {
                let partialConflict = collaborators.contains { collaborator in
                    let artistConflicts = artistName.map { SiriNameNormalizer.normalize(collaborator.artistName) == SiriNameNormalizer.normalize($0) } ?? false
                    let songwriterConflicts = songwriterName.map { SiriNameNormalizer.normalize(collaborator.songwriterName) == SiriNameNormalizer.normalize($0) } ?? false
                    return artistConflicts || songwriterConflicts
                }
                if partialConflict { throw SiriDataError.collaboratorDetailsConflict }
                guard hasProAccess || collaborators.count < FreeTierLimits.collaborators else { throw SiriDataError.freeCollaboratorLimitReached }
                createsCollaborator = true
            }
        } else if request.collaboratorPRO != nil || ipi != nil {
            throw SiriDataError.missingCollaboratorName
        }

        let hasCollaborator = collaboratorID != nil || createsCollaborator
        if (!request.contributions.isEmpty || request.masterSplit != nil || request.publishingSplit != nil) && !hasCollaborator {
            throw SiriDataError.collaboratorRequiredForCredits
        }

        let duplicateTitleExists = songs.contains {
            SiriNameNormalizer.normalize($0.title) == SiriNameNormalizer.normalize(title)
        }
        let primaryContributions = hasProAccess ? profile.defaultContributions : []
        let collaboratorContributions: Set<Contribution>
        if !request.contributions.isEmpty {
            collaboratorContributions = request.contributions
        } else if hasProAccess, let collaboratorID,
                  let collaborator = collaborators.first(where: { $0.id == collaboratorID }) {
            collaboratorContributions = collaborator.defaultContributions
        } else {
            collaboratorContributions = []
        }
        let confirmation = SiriSongCreditConfirmation.build(
            title: title,
            phase: request.phase,
            releaseDate: request.releaseDate,
            profileArtistName: profile.artistName,
            collaboratorArtistName: resolvedArtistName,
            collaboratorSongwriterName: resolvedSongwriterName,
            createsCollaborator: createsCollaborator,
            contribution: request.contributions.first,
            requestedMasterSplit: request.masterSplit,
            requestedPublishingSplit: request.publishingSplit,
            duplicateTitleExists: duplicateTitleExists
        )

        return SiriSongCreditPlan(
            request: request,
            title: title,
            collaboratorID: collaboratorID,
            collaboratorArtistName: resolvedArtistName,
            collaboratorSongwriterName: resolvedSongwriterName,
            createsCollaborator: createsCollaborator,
            duplicateTitleExists: duplicateTitleExists,
            masterSplit: request.masterSplit ?? 0,
            publishingSplit: request.publishingSplit ?? 0,
            profileArtistName: profile.artistName,
            profileSongwriterName: profile.songwriterName,
            profileDistributor: profile.distributor,
            primaryContributions: primaryContributions,
            collaboratorContributions: collaboratorContributions,
            confirmation: confirmation
        )
    }
}
