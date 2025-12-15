import Foundation
import CoreData
import Combine

@MainActor
final class AppStateViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile
    @Published private(set) var songs: [Song]
    @Published private(set) var collaborators: [Collaborator]

    let context: NSManagedObjectContext
    var profileObjectID: NSManagedObjectID?

    init(context: NSManagedObjectContext, seedForPreview: Bool = false) {
        self.context = context
        if seedForPreview {
            Self.seedPreviewData(in: context)
        }

        let snapshot = Self.loadSnapshot(from: context)
        self.profile = snapshot.profile
        self.songs = snapshot.songs
        self.collaborators = snapshot.collaborators
        self.profileObjectID = snapshot.profileObjectID
    }

    // MARK: Profile

    func updateProfile(artistName: String, songwriterName: String, mainPRO: PRO, distributor: Distributor, ipi: String, defaultContributions: Set<Contribution>, completeOnboarding: Bool? = nil) {
        guard let profileObjectID else { return }
        do {
            if let profileObject = try context.existingObject(with: profileObjectID) as? UserProfileEntity {
                profileObject.artistName = artistName
                profileObject.songwriterName = songwriterName
                profileObject.mainPRO = mainPRO.rawValue
                profileObject.distributorPreset = distributor.preset.rawValue
                profileObject.distributorCustomName = distributor.customName
                profileObject.ipi = ipi
                profileObject.defaultContributionsRaw = Self.encodeContributions(defaultContributions)
                if let completeOnboarding {
                    profileObject.hasCompletedOnboarding = completeOnboarding
                }

                let songRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
                if let songs = try? context.fetch(songRequest) {
                    songs.forEach { song in
                        song.primaryArtist = artistName
                        song.primarySongwriter = songwriterName
                        song.distributorPreset = distributor.preset.rawValue
                        song.distributorCustomName = distributor.customName
                    }
                }
                try saveAndRefresh()
            }
        } catch {
            print("Failed to update profile: \(error)")
        }
    }

    func setMainPRO(_ pro: PRO) {
        updateProfile(
            artistName: profile.artistName,
            songwriterName: profile.songwriterName,
            mainPRO: pro,
            distributor: profile.distributor,
            ipi: profile.ipi,
            defaultContributions: profile.defaultContributions
        )
    }

    func markOnboardingComplete() {
        updateProfile(
            artistName: profile.artistName,
            songwriterName: profile.songwriterName,
            mainPRO: profile.mainPRO,
            distributor: profile.distributor,
            ipi: profile.ipi,
            defaultContributions: profile.defaultContributions,
            completeOnboarding: true
        )
    }

    // MARK: Collaborators

    @discardableResult
    func addCollaborator(artistName: String, songwriterName: String, preferredPRO: PRO?, defaultContributions: Set<Contribution> = [], ipi: String? = nil) -> Collaborator {
        let collaborator = CollaboratorEntity(context: context)
        collaborator.id = UUID()
        collaborator.artistName = artistName
        collaborator.songwriterName = songwriterName
        collaborator.preferredPRO = preferredPRO?.rawValue
        collaborator.defaultContributionsRaw = Self.encodeContributions(defaultContributions)
        collaborator.ipi = ipi
        collaborator.createdAt = Date()

        do {
            try saveAndRefresh()
        } catch {
            print("Failed to add collaborator: \(error)")
        }

        return collaborators.first(where: { $0.id == collaborator.id }) ?? Collaborator(artistName: artistName, songwriterName: songwriterName, preferredPRO: preferredPRO, defaultContributions: defaultContributions, ipi: ipi)
    }

    func updateCollaborator(_ collaborator: Collaborator) {
        let request: NSFetchRequest<CollaboratorEntity> = CollaboratorEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", collaborator.id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else { return }
            entity.artistName = collaborator.artistName
            entity.songwriterName = collaborator.songwriterName
            entity.preferredPRO = collaborator.preferredPRO?.rawValue
            entity.defaultContributionsRaw = Self.encodeContributions(collaborator.defaultContributions)
            entity.ipi = collaborator.ipi
            try saveAndRefresh()
        } catch {
            print("Failed to update collaborator: \(error)")
        }
    }

    func deleteCollaborators(ids: [UUID]) {
        guard ids.isEmpty == false else { return }
        let request: NSFetchRequest<CollaboratorEntity> = CollaboratorEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)

        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            try saveAndRefresh()
        } catch {
            print("Failed to delete collaborators: \(error)")
        }
    }

    // MARK: Songs

    @discardableResult
    func addSong(title: String, phase: SongPhase, releaseDate: Date?, collaboratorIDs: Set<UUID>, checklist: RegistrationChecklist, collaboratorSplits: [UUID: SplitAllocation], primarySplits: SplitAllocation, collaboratorContributions: [UUID: Set<Contribution>], primaryContributions: Set<Contribution>, links: [SongLink], isrc: String?, iswc: String?, upc: String?) -> Song {
        let song = SongEntity(context: context)
        song.id = UUID()
        song.title = title.isEmpty ? "Untitled" : title
        song.createdAt = Date()
        song.releaseDate = releaseDate
        song.phase = phase.rawValue
        song.primaryArtist = profile.artistName
        song.primarySongwriter = profile.songwriterName
        song.distributorPreset = profile.distributor.preset.rawValue
        song.distributorCustomName = profile.distributor.customName
        song.checklistPro = checklist.pro
        song.checklistMlc = checklist.mlc
        song.checklistHfa = checklist.hfa
        song.checklistSoundExchange = checklist.soundExchange
        song.checklistMusicReports = checklist.musicReports
        song.checklistDistributorSubmitted = checklist.distributorSubmitted
        song.primarySplitsMaster = primarySplits.master
        song.primarySplitsPublishing = primarySplits.publishing
        song.primaryContributionsRaw = Self.encodeContributions(primaryContributions)
        song.isrc = isrc
        song.iswc = iswc
        song.upc = upc
        song.notes = ""

        attachCollaborators(to: song, collaboratorIDs: collaboratorIDs, splits: collaboratorSplits, contributions: collaboratorContributions)
        attachLinks(to: song, links: links)

        do {
            try saveAndRefresh()
        } catch {
            print("Failed to add song: \(error)")
        }

        let sanitizedLinks = Self.normalizedLinks(links)
        return songs.first(where: { $0.id == song.id }) ?? Song(
            id: song.id ?? UUID(),
            title: song.title ?? "Untitled",
            createdAt: song.createdAt ?? Date(),
            releaseDate: song.releaseDate,
            phase: phase,
            mediaLibraryPersistentID: song.mediaLibraryPersistentID == 0 ? nil : UInt64(song.mediaLibraryPersistentID),
            primaryArtist: profile.artistName,
            primarySongwriter: profile.songwriterName,
            notes: "",
            collaborators: [],
            links: sanitizedLinks,
            distributor: profile.distributor,
            checklist: checklist,
            primarySplits: primarySplits,
            collaboratorSplits: collaboratorSplits,
            primaryContributions: primaryContributions,
            collaboratorContributions: collaboratorContributions,
            isrc: isrc,
            iswc: iswc,
            upc: upc
        )
    }

    @discardableResult
    func importSongs(_ payloads: [SongImportPayload]) -> SongImportResult {
        let result = SongImportService.importSongs(payloads, context: context, profile: profile)
        do {
            try saveAndRefresh()
        } catch {
            print("Failed to import songs: \(error)")
        }
        return result
    }

    func linkSongToLibrary(id: UUID, payload: SongImportPayload) {
        guard let songEntity = fetchSong(by: id) else { return }
        songEntity.mediaLibraryPersistentID = Int64(payload.persistentID ?? 0)
        let linkNote = SongImportService.buildNote(from: payload)
        if let existing = songEntity.notes, existing.isEmpty == false {
            songEntity.notes = existing + "\n" + linkNote
        } else {
            songEntity.notes = linkNote
        }
        do {
            try saveAndRefresh()
        } catch {
            print("Failed to link song to library: \(error)")
        }
    }

    func updateSong(id: UUID, title: String, phase: SongPhase, releaseDate: Date?, collaboratorIDs: Set<UUID>, checklist: RegistrationChecklist, collaboratorSplits: [UUID: SplitAllocation], primarySplits: SplitAllocation, collaboratorContributions: [UUID: Set<Contribution>], primaryContributions: Set<Contribution>, links: [SongLink], isrc: String?, iswc: String?, upc: String?) {
        guard let songEntity = fetchSong(by: id) else { return }

        songEntity.title = title.isEmpty ? "Untitled" : title
        songEntity.phase = phase.rawValue
        songEntity.releaseDate = releaseDate
        songEntity.primaryArtist = profile.artistName
        songEntity.primarySongwriter = profile.songwriterName
        songEntity.distributorPreset = profile.distributor.preset.rawValue
        songEntity.distributorCustomName = profile.distributor.customName
        songEntity.checklistPro = checklist.pro
        songEntity.checklistMlc = checklist.mlc
        songEntity.checklistHfa = checklist.hfa
        songEntity.checklistSoundExchange = checklist.soundExchange
        songEntity.checklistMusicReports = checklist.musicReports
        songEntity.checklistDistributorSubmitted = checklist.distributorSubmitted
        songEntity.primarySplitsMaster = primarySplits.master
        songEntity.primarySplitsPublishing = primarySplits.publishing
        songEntity.primaryContributionsRaw = Self.encodeContributions(primaryContributions)
        songEntity.isrc = isrc
        songEntity.iswc = iswc
        songEntity.upc = upc

        // Clear old links then recreate for current collaborators
        if let links = songEntity.songLinks as? Set<SongCollaboratorLinkEntity> {
            links.forEach { context.delete($0) }
        }
        attachCollaborators(to: songEntity, collaboratorIDs: collaboratorIDs, splits: collaboratorSplits, contributions: collaboratorContributions)
        if let externalLinks = songEntity.externalLinks as? Set<SongLinkEntity> {
            externalLinks.forEach { context.delete($0) }
        }
        attachLinks(to: songEntity, links: links)

        do {
            try saveAndRefresh()
        } catch {
            print("Failed to update song: \(error)")
        }
    }

    func updateSongNotes(id: UUID, notes: String) {
        guard let songEntity = fetchSong(by: id) else { return }
        songEntity.notes = notes
        do {
            try saveAndRefresh()
        } catch {
            print("Failed to update song notes: \(error)")
        }
    }

    func updateSongPhase(id: UUID, phase: SongPhase) {
        guard let songEntity = fetchSong(by: id) else { return }
        songEntity.phase = phase.rawValue
        do {
            try saveAndRefresh()
        } catch {
            print("Failed to update song phase: \(error)")
        }
    }

    func toggleChecklist(for songID: UUID, keyPath: WritableKeyPath<RegistrationChecklist, Bool>) {
        guard let songEntity = fetchSong(by: songID) else { return }
        switch keyPath {
        case \.pro: songEntity.checklistPro.toggle()
        case \.mlc: songEntity.checklistMlc.toggle()
        case \.hfa: songEntity.checklistHfa.toggle()
        case \.soundExchange: songEntity.checklistSoundExchange.toggle()
        case \.musicReports: songEntity.checklistMusicReports.toggle()
        case \.distributorSubmitted: songEntity.checklistDistributorSubmitted.toggle()
        default: break
        }

        do {
            try saveAndRefresh()
        } catch {
            print("Failed to toggle checklist: \(error)")
        }
    }

    func deleteSongs(ids: [UUID]) {
        guard ids.isEmpty == false else { return }
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)

        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            try saveAndRefresh()
        } catch {
            print("Failed to delete songs: \(error)")
        }
    }

    // MARK: Private helpers

    func attachCollaborators(to song: SongEntity, collaboratorIDs: Set<UUID>, splits: [UUID: SplitAllocation], contributions: [UUID: Set<Contribution>]) {
        guard collaboratorIDs.isEmpty == false else { return }
        let request: NSFetchRequest<CollaboratorEntity> = CollaboratorEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", collaboratorIDs)

        guard let collaborators = try? context.fetch(request) else { return }

        collaborators.forEach { collaborator in
            let link = SongCollaboratorLinkEntity(context: context)
            link.id = UUID()
            link.collaborator = collaborator
            link.song = song
            if let collaboratorID = collaborator.id {
                let allocation = splits[collaboratorID] ?? .zero
                link.masterSplit = allocation.master
                link.publishingSplit = allocation.publishing
                let fallback = Self.decodeContributions(collaborator.defaultContributionsRaw)
                link.contributionsRaw = Self.encodeContributions(contributions[collaboratorID] ?? fallback)
            }
        }
    }

    private func attachLinks(to song: SongEntity, links: [SongLink]) {
        let filtered = Self.normalizedLinks(links)
        guard filtered.isEmpty == false else { return }
        filtered.forEach { link in
            let linkEntity = SongLinkEntity(context: context)
            linkEntity.id = link.id
            linkEntity.title = link.title
            linkEntity.urlString = link.urlString
            linkEntity.createdAt = Date()
            linkEntity.song = song
        }
    }

    func fetchSong(by id: UUID) -> SongEntity? {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    func saveAndRefresh() throws {
        if context.hasChanges {
            try context.save()
        }
        let snapshot = Self.loadSnapshot(from: context)
        self.profile = snapshot.profile
        self.songs = snapshot.songs
        self.collaborators = snapshot.collaborators
        self.profileObjectID = snapshot.profileObjectID
    }

    private static func loadSnapshot(from context: NSManagedObjectContext) -> (profile: UserProfile, songs: [Song], collaborators: [Collaborator], profileObjectID: NSManagedObjectID?) {
        let profileEntity = loadOrCreateProfile(in: context)
        let collaborators = loadCollaborators(in: context)
        let songs = loadSongs(in: context, collaborators: collaborators)
        return (profile: mapProfile(from: profileEntity), songs: songs, collaborators: collaborators, profileObjectID: profileEntity.objectID)
    }

    private static func loadOrCreateProfile(in context: NSManagedObjectContext) -> UserProfileEntity {
        let request: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        request.fetchLimit = 1
        if let existing = try? context.fetch(request).first {
            return existing
        }

        let profile = UserProfileEntity(context: context)
        profile.id = UUID()
        profile.artistName = ""
        profile.songwriterName = ""
        profile.mainPRO = PRO.ascap.rawValue
        profile.distributorPreset = DistributorPreset.distrokid.rawValue
        profile.defaultContributionsRaw = encodeContributions([])
        profile.hasCompletedOnboarding = false
        profile.createdAt = Date()

        do {
            try context.save()
        } catch {
            print("Failed to seed profile: \(error)")
        }

        return profile
    }

    private static func loadCollaborators(in context: NSManagedObjectContext) -> [Collaborator] {
        let request: NSFetchRequest<CollaboratorEntity> = CollaboratorEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        guard let entities = try? context.fetch(request) else { return [] }
        return entities.map { mapCollaborator(from: $0) }
    }

    private static func loadSongs(in context: NSManagedObjectContext, collaborators: [Collaborator]) -> [Song] {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let collaboratorLookup = Dictionary(uniqueKeysWithValues: collaborators.map { ($0.id, $0) })

        guard let entities = try? context.fetch(request) else { return [] }
        return entities.map { mapSong(from: $0, collaboratorLookup: collaboratorLookup) }
    }

    private static func mapProfile(from entity: UserProfileEntity) -> UserProfile {
        let proRaw = entity.mainPRO ?? PRO.ascap.rawValue
        let distributorPreset = entity.distributorPreset ?? DistributorPreset.distrokid.rawValue
        return UserProfile(
            artistName: entity.artistName ?? "",
            songwriterName: entity.songwriterName ?? "",
            mainPRO: PRO(rawValue: proRaw) ?? .ascap,
            distributor: Distributor(preset: DistributorPreset(rawValue: distributorPreset) ?? .distrokid, customName: entity.distributorCustomName),
            ipi: entity.ipi ?? "",
            defaultContributions: decodeContributions(entity.defaultContributionsRaw),
            hasCompletedOnboarding: entity.hasCompletedOnboarding
        )
    }

    private static func mapCollaborator(from entity: CollaboratorEntity) -> Collaborator {
        Collaborator(
            id: entity.id ?? UUID(),
            artistName: entity.artistName ?? "",
            songwriterName: entity.songwriterName ?? "",
            preferredPRO: entity.preferredPRO.flatMap { PRO(rawValue: $0) },
            defaultContributions: decodeContributions(entity.defaultContributionsRaw),
            ipi: entity.ipi
        )
    }

    private static func mapSong(from entity: SongEntity, collaboratorLookup: [UUID: Collaborator]) -> Song {
        let links = (entity.songLinks as? Set<SongCollaboratorLinkEntity>) ?? []
        let externalLinks = (entity.externalLinks as? Set<SongLinkEntity>) ?? []
        let sortedExternalLinks = externalLinks.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }

        var collaborators: [Collaborator] = []
        var collaboratorSplits: [UUID: SplitAllocation] = [:]
        var collaboratorContributions: [UUID: Set<Contribution>] = [:]

        for link in links {
            guard let collaboratorID = link.collaborator?.id else { continue }
            if let collaborator = collaboratorLookup[collaboratorID] {
                collaborators.append(collaborator)
            }
            collaboratorSplits[collaboratorID] = SplitAllocation(master: link.masterSplit, publishing: link.publishingSplit)
            collaboratorContributions[collaboratorID] = decodeContributions(link.contributionsRaw)
        }

        let distributor = Distributor(
            preset: DistributorPreset(rawValue: entity.distributorPreset ?? DistributorPreset.distrokid.rawValue) ?? .distrokid,
            customName: entity.distributorCustomName
        )

        let checklist = RegistrationChecklist(
            pro: entity.checklistPro,
            mlc: entity.checklistMlc,
            hfa: entity.checklistHfa,
            soundExchange: entity.checklistSoundExchange,
            musicReports: entity.checklistMusicReports,
            distributorSubmitted: entity.checklistDistributorSubmitted
        )

        return Song(
            id: entity.id ?? UUID(),
            title: entity.title ?? "Untitled",
            createdAt: entity.createdAt ?? Date(),
            releaseDate: entity.releaseDate,
            phase: SongPhase(rawValue: entity.phase ?? SongPhase.pending.rawValue) ?? .pending,
            mediaLibraryPersistentID: entity.mediaLibraryPersistentID == 0 ? nil : UInt64(entity.mediaLibraryPersistentID),
            primaryArtist: entity.primaryArtist ?? "",
            primarySongwriter: entity.primarySongwriter ?? "",
            notes: entity.notes ?? "",
            collaborators: collaborators,
            links: sortedExternalLinks.map { SongLink(id: $0.id ?? UUID(), title: $0.title ?? "Link", urlString: $0.urlString ?? "") },
            distributor: distributor,
            checklist: checklist,
            primarySplits: SplitAllocation(master: entity.primarySplitsMaster, publishing: entity.primarySplitsPublishing),
            collaboratorSplits: collaboratorSplits,
            primaryContributions: decodeContributions(entity.primaryContributionsRaw),
            collaboratorContributions: collaboratorContributions,
            isrc: entity.isrc,
            iswc: entity.iswc,
            upc: entity.upc
        )
    }

    static func encodeContributions(_ contributions: Set<Contribution>) -> String {
        let rawValues = contributions.map { $0.rawValue }
        guard let data = try? JSONEncoder().encode(rawValues) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    static func decodeContributions(_ raw: String?) -> Set<Contribution> {
        guard let raw, let data = raw.data(using: .utf8), let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(decoded.compactMap { Contribution(rawValue: $0) })
    }

    private static func normalizedLinks(_ links: [SongLink]) -> [SongLink] {
        let trimmed = links.map { link in
            SongLink(id: link.id, title: link.title.trimmingCharacters(in: .whitespacesAndNewlines), urlString: link.urlString.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        let valid = trimmed.filter { link in
            guard link.title.isEmpty == false else { return false }
            guard let url = URL(string: link.urlString), let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else { return false }
            return true
        }
        return Array(valid.prefix(5))
    }

    private static func seedPreviewData(in context: NSManagedObjectContext) {
        let songRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        if let existingSongs = try? context.fetch(songRequest), existingSongs.isEmpty == false {
            return
        }

        // Lightweight preview data without shipping to production users.
        let profile = loadOrCreateProfile(in: context)
        profile.artistName = "Nova Sky"
        profile.songwriterName = "Aria Lane"
        profile.ipi = "123456789"
        profile.defaultContributionsRaw = encodeContributions([.songwriter, .producer])
        profile.hasCompletedOnboarding = true

        let collaboratorA = CollaboratorEntity(context: context)
        collaboratorA.id = UUID()
        collaboratorA.artistName = "Echo Reyes"
        collaboratorA.songwriterName = "Echo Reyes"
        collaboratorA.preferredPRO = PRO.bmi.rawValue
        collaboratorA.defaultContributionsRaw = encodeContributions([.featuredArtist, .instrumentalist])
        collaboratorA.ipi = "888888888"
        collaboratorA.createdAt = Date()

        let collaboratorB = CollaboratorEntity(context: context)
        collaboratorB.id = UUID()
        collaboratorB.artistName = "Miles Hart"
        collaboratorB.songwriterName = "Miles Hart"
        collaboratorB.preferredPRO = PRO.sesac.rawValue
        collaboratorB.defaultContributionsRaw = encodeContributions([.producer, .beatmaker])
        collaboratorB.ipi = "777777777"
        collaboratorB.createdAt = Date().addingTimeInterval(-3600)

        let song = SongEntity(context: context)
        song.id = UUID()
        song.title = "Neon Skyline"
        song.createdAt = Date()
        song.phase = SongPhase.mixing.rawValue
        song.primaryArtist = profile.artistName
        song.primarySongwriter = profile.songwriterName
        song.distributorPreset = DistributorPreset.distrokid.rawValue
        song.checklistPro = true
        song.checklistMlc = true
        song.checklistHfa = true
        song.primarySplitsMaster = 70
        song.primarySplitsPublishing = 70
        song.primaryContributionsRaw = encodeContributions([.songwriter, .producer])
        song.notes = "Try tighter hook + whispered BVs on pre."

        let linkA = SongCollaboratorLinkEntity(context: context)
        linkA.id = UUID()
        linkA.collaborator = collaboratorA
        linkA.song = song
        linkA.masterSplit = 15
        linkA.publishingSplit = 15
        linkA.contributionsRaw = collaboratorA.defaultContributionsRaw

        let linkB = SongCollaboratorLinkEntity(context: context)
        linkB.id = UUID()
        linkB.collaborator = collaboratorB
        linkB.song = song
        linkB.masterSplit = 15
        linkB.publishingSplit = 15
        linkB.contributionsRaw = collaboratorB.defaultContributionsRaw

        let externalLink = SongLinkEntity(context: context)
        externalLink.id = UUID()
        externalLink.title = "Reference Mix"
        externalLink.urlString = "https://example.com/mix"
        externalLink.createdAt = Date()
        externalLink.song = song

        do {
            try context.save()
        } catch {
            print("Failed to seed preview data: \(error)")
        }
    }

    @MainActor
    static func preview() -> AppStateViewModel {
        AppStateViewModel(context: PersistenceController.preview.container.viewContext, seedForPreview: true)
    }

    @MainActor
    static func live() -> AppStateViewModel {
        if let liveViewModel { return liveViewModel }
        let viewModel = AppStateViewModel(context: PersistenceController.shared.container.viewContext)
        liveViewModel = viewModel
        return viewModel
    }

    private static var liveViewModel: AppStateViewModel?
}
