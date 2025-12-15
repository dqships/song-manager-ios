import SwiftUI
import RevenueCatUI
import MediaPlayer
import UIKit

struct SongsHomeView: View {
    @EnvironmentObject var viewModel: AppStateViewModel
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var playbackController: MusicPlaybackController
    @State private var isAddingSong = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .recent
    @State private var phaseFilter: SongPhase? = nil
    @State private var registrationFilter: RegistrationOrg? = nil
    @State private var collaboratorFilter: CollaboratorFilter = .any
    @State private var toastMessage: String?
    @State private var showPaywall = false
    @State private var showPlaybackAlert = false
    @State private var playbackAlertMessage = ""
    @State private var showMusicPicker = false
    @State private var showMusicDeniedAlert = false
    @State private var showLimitAlert = false
    @State private var pendingImports: [SongImportPayload] = []
    @State private var limitSelectionCount: Int = 0
    @State private var allowedImportCount: Int = SongImportService.importLimit

    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    Section(header: Text("Songs")) {
                        if processedSongs.isEmpty {
                            Text("No songs yet. Add your first idea to link it with your names and collaborators.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(processedSongs) { song in
                                NavigationLink {
                                    SongDetailView(song: song)
                                        .environmentObject(viewModel)
                                } label: {
                                    SongRow(song: song) { persistentID in
                                        playbackController.toggle(for: persistentID) { message in
                                            playbackAlertMessage = message
                                            showPlaybackAlert = true
                                        }
                                    }
                                }
                            }
                            .onDelete { offsets in
                                let ids = offsets.map { processedSongs[$0].id }
                                viewModel.deleteSongs(ids: ids)
                            }
                        }
                    }
                }
                .navigationTitle("Catalog")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            filterMenu
                            Menu {
                                Button {
                                    presentManualAdd()
                                } label: {
                                    Label("Add Song", systemImage: "square.and.pencil")
                                }
                                Button {
                                    startLibraryImport()
                                } label: {
                                    Label("Import from Music Library", systemImage: "music.note.list")
                                }
                            } label: {
                                Label("Add", systemImage: "plus")
                            }
                        }
                    }
                }
                .sheet(isPresented: $isAddingSong) {
                    SongFormView(mode: .create) { title, phase, releaseDate, collaboratorIDs, checklist, collaboratorSplits, primarySplits, collaboratorContributions, primaryContributions, links, isrc, iswc, upc in
                        viewModel.addSong(
                            title: title,
                            phase: phase,
                            releaseDate: releaseDate,
                            collaboratorIDs: collaboratorIDs,
                            checklist: checklist,
                            collaboratorSplits: collaboratorSplits,
                            primarySplits: primarySplits,
                            collaboratorContributions: collaboratorContributions,
                            primaryContributions: primaryContributions,
                            links: links,
                            isrc: isrc,
                            iswc: iswc,
                            upc: upc
                        )
                    }
                    .environmentObject(viewModel)
                }
                .searchable(text: $searchText, prompt: "Search songs or collaborators")
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .background(Color.paletteBackground)
            }
            .background(Color.paletteBackground)

            if let toastMessage {
                VStack {
                    ToastBanner(message: toastMessage, actionTitle: "Go Pro") {
                        showPaywall = true
                    }
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            if self.toastMessage == toastMessage {
                                self.toastMessage = nil
                            }
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: toastMessage)
        .keyboardDismissal()
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showMusicPicker) {
            MusicImportPicker {
                handlePickedPayloads($0)
            } onCancel: {
                showMusicPicker = false
            }
        }
        .alert("Music Library Access Needed", isPresented: $showMusicDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Allow library access so we can import your songs.")
        }
        .alert("Import limit is \(allowedImportCount)", isPresented: $showLimitAlert) {
            Button("Import first \(allowedImportCount)") {
                performLibraryImport(Array(pendingImports.prefix(allowedImportCount)), forcedLimitNotice: true)
                pendingImports = []
            }
            Button("Reselect", role: .cancel) {
                pendingImports = []
            }
        } message: {
            Text("You selected \(limitSelectionCount) songs. You can import up to \(allowedImportCount) right now.")
        }
        .alert("Playback unavailable", isPresented: $showPlaybackAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(playbackAlertMessage)
        }
    }

    private var processedSongs: [Song] {
        let filtered = viewModel.songs.filter { song in
            matchesSearch(song) &&
            matchesPhase(song) &&
            matchesRegistration(song) &&
            matchesCollaboratorFilter(song)
        }
        switch sortOption {
        case .recent:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .alphabetical:
            return filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .releaseDate:
            return filtered.sorted { lhs, rhs in
                switch (lhs.releaseDate, rhs.releaseDate) {
                case let (l?, r?):
                    return l > r
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return lhs.createdAt > rhs.createdAt
                }
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            Picker("Sort", selection: $sortOption) {
                ForEach(SortOption.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.menu)

            Picker("Phase", selection: Binding(
                get: { phaseFilter },
                set: { phaseFilter = $0 }
            )) {
                Text("Any phase").tag(SongPhase?.none)
                ForEach(SongPhase.allCases) { phase in
                    Text(phase.rawValue).tag(SongPhase?.some(phase))
                }
            }

            Picker("Registration", selection: Binding(
                get: { registrationFilter },
                set: { registrationFilter = $0 }
            )) {
                Text("Any registration").tag(RegistrationOrg?.none)
                ForEach(RegistrationOrg.allCases) { org in
                    Text(org.label).tag(RegistrationOrg?.some(org))
                }
            }

            Picker("Collaborators", selection: Binding(
                get: { collaboratorFilter },
                set: { collaboratorFilter = $0 }
            )) {
                Text("Any collaborators").tag(CollaboratorFilter.any)
                Text("Solo only").tag(CollaboratorFilter.solo)
                ForEach(viewModel.collaborators) { collaborator in
                    Text(collaborator.artistName).tag(CollaboratorFilter.named(collaborator.id))
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }

    private func handleAddSongTapped() {
        if subscriptionService.hasProAccess == false && viewModel.songs.count >= FreeTierLimits.songs {
            withAnimation {
                toastMessage = "Need more than \(FreeTierLimits.songs) songs? Go Pro to add more."
            }
            return
        }
        isAddingSong = true
    }

    private func presentManualAdd() {
        handleAddSongTapped()
    }

    private func startLibraryImport() {
        let available = availableSlots()
        guard available > 0 else {
            withAnimation {
                toastMessage = "Need more than \(FreeTierLimits.songs) songs? Go Pro to import more."
            }
            return
        }
        requestMusicAccess()
    }

    private func availableSlots() -> Int {
        if subscriptionService.hasProAccess {
            return SongImportService.importLimit
        }
        let remaining = FreeTierLimits.songs - viewModel.songs.count
        return max(0, min(SongImportService.importLimit, remaining))
    }

    private func requestMusicAccess() {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            showMusicPicker = true
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        showMusicPicker = true
                    } else {
                        showMusicDeniedAlert = true
                    }
                }
            }
        default:
            showMusicDeniedAlert = true
        }
    }

    private func handlePickedPayloads(_ payloads: [SongImportPayload]) {
        showMusicPicker = false
        let normalized = SongImportService.normalizePayloads(payloads)
        guard normalized.isEmpty == false else {
            withAnimation { toastMessage = "No song titles were imported." }
            return
        }

        let maxAllowed = availableSlots()
        guard maxAllowed > 0 else {
            withAnimation {
                toastMessage = "Need more than \(FreeTierLimits.songs) songs? Go Pro to import more."
            }
            return
        }

        allowedImportCount = maxAllowed
        if normalized.count > maxAllowed {
            pendingImports = normalized
            limitSelectionCount = normalized.count
            showLimitAlert = true
        } else {
            performLibraryImport(normalized)
        }
    }

    private func performLibraryImport(_ payloads: [SongImportPayload], forcedLimitNotice: Bool = false) {
        let capped = Array(payloads.prefix(allowedImportCount))
        let result = viewModel.importSongs(capped)
        var message = "Imported \(result.importedCount) song\(result.importedCount == 1 ? "" : "s")."
        if forcedLimitNotice || result.limitedByCap || capped.count < payloads.count {
            message.append(" Limited to \(allowedImportCount) right now.")
        }
        if result.skippedExistingTitles.isEmpty == false {
            message.append(" Skipped \(result.skippedExistingTitles.count) existing title\(result.skippedExistingTitles.count == 1 ? "" : "s").")
        }
        withAnimation {
            toastMessage = message
        }
    }

    private func matchesSearch(_ song: Song) -> Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        let text = trimmed.lowercased()
        if song.title.lowercased().contains(text) { return true }
        return song.collaborators.contains { collaborator in
            collaborator.artistName.lowercased().contains(text) || collaborator.songwriterName.lowercased().contains(text)
        }
    }

    private func matchesPhase(_ song: Song) -> Bool {
        guard let filter = phaseFilter else { return true }
        return song.phase == filter
    }

    private func matchesRegistration(_ song: Song) -> Bool {
        guard let filter = registrationFilter else { return true }
        switch filter {
        case .pro:
            return song.checklist.pro
        case .mlc:
            return song.checklist.mlc
        case .hfa:
            return song.checklist.hfa
        case .soundExchange:
            return song.checklist.soundExchange
        case .musicReports:
            return song.checklist.musicReports
        case .distributor:
            return song.checklist.distributorSubmitted
        }
    }

    private func matchesCollaboratorFilter(_ song: Song) -> Bool {
        switch collaboratorFilter {
        case .any:
            return true
        case .solo:
            return song.collaborators.isEmpty
        case .named(let collaboratorID):
            return song.collaborators.contains { $0.id == collaboratorID }
        }
    }
}

private struct SongRow: View {
    let song: Song
    var onPlay: (UInt64) -> Void
    @EnvironmentObject var playbackController: MusicPlaybackController

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(song.title)
                    .font(.headline)
                Spacer()
                if let persistentID = song.mediaLibraryPersistentID {
                    Button {
                        onPlay(persistentID)
                    } label: {
                        Image(systemName: playbackController.isPlaying(persistentID: persistentID) ? "pause.fill" : "play.fill")
                    }
                    .buttonStyle(.borderless)
                    .tint(.paletteBrick)
                }
                PhaseTag(phase: song.phase)
            }
            Text("Artist: \(song.primaryArtist)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let releaseDate = song.releaseDate {
                Text("Release: \(releaseDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if !song.collaborators.isEmpty {
                Text("Collaborators: \(song.collaborators.map { $0.artistName }.joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if !song.links.isEmpty {
                Text("Links: \(song.links.count)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                ProgressView(value: songPhaseProgress(for: song.phase), total: 1.0)
                    .progressViewStyle(.linear)
                Text(phaseStepLabel(for: song.phase))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func songPhaseProgress(for phase: SongPhase) -> Double {
        let orderedPhases: [SongPhase] = [.pending, .writing, .recording, .mixing, .mastering, .completed]
        guard let index = orderedPhases.firstIndex(of: phase) else { return 0 }
        return Double(index) / Double(max(orderedPhases.count - 1, 1))
    }

    private func phaseStepLabel(for phase: SongPhase) -> String {
        let orderedPhases: [SongPhase] = [.pending, .writing, .recording, .mixing, .mastering, .completed]
        guard let index = orderedPhases.firstIndex(of: phase) else { return "" }
        let stageNumber = index + 1
        return "Phase \(stageNumber)/\(orderedPhases.count)"
    }
}

struct PhaseTag: View {
    let phase: SongPhase

    var body: some View {
        Text(phase.rawValue)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.paletteSurface)
            .clipShape(Capsule())
    }
}

private enum SortOption: String, CaseIterable, Identifiable {
    case recent
    case alphabetical
    case releaseDate

    var id: String { rawValue }
    var label: String {
        switch self {
        case .recent: return "Most Recent"
        case .alphabetical: return "Alphabetical"
        case .releaseDate: return "Release Date"
        }
    }
}

private enum RegistrationOrg: String, CaseIterable, Identifiable {
    case pro
    case mlc
    case hfa
    case soundExchange
    case musicReports
    case distributor

    var id: String { rawValue }
    var label: String {
        switch self {
        case .pro: return "PRO"
        case .mlc: return "MLC"
        case .hfa: return "HFA"
        case .soundExchange: return "SoundExchange"
        case .musicReports: return "Music Reports"
        case .distributor: return "Distributor"
        }
    }
}

private enum CollaboratorFilter: Hashable, Identifiable {
    case any
    case solo
    case named(UUID)

    var id: String {
        switch self {
        case .any: return "any"
        case .solo: return "solo"
        case .named(let id): return id.uuidString
        }
    }
}
