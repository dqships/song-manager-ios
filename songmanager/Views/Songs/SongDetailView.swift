import SwiftUI
import RevenueCatUI
import MediaPlayer

struct SongDetailView: View {
    @EnvironmentObject var viewModel: AppStateViewModel
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var playbackController: MusicPlaybackController
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let song: Song
    @State private var isEditing = false
    @State private var selectedTab: DetailTab = .overview
    @State private var notesText = ""
    @State private var isEditingNotes = false
    @State private var showPaywall = false
    @State private var showPlaybackAlert = false
    @State private var playbackAlertMessage = ""
    @State private var showLinkPicker = false

    var body: some View {
        List {
            Section {
                Picker("View", selection: $selectedTab) {
                    ForEach(DetailTab.allCases) { tab in
                        Text(tab.label).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
            }

            switch selectedTab {
            case .overview:
                overviewContent
            case .notes:
                notesContent
            case .advanced:
                advancedContent
            }
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .background(Color.paletteBackground)
        .navigationTitle("Song")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    if selectedTab == .notes {
                        notesText = resolvedSong.notes
                        isEditingNotes = true
                    } else {
                        isEditing = true
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            SongFormView(mode: .edit(existing: resolvedSong)) { title, phase, releaseDate, collaboratorIDs, checklist, collaboratorSplits, primarySplits, collaboratorContributions, primaryContributions, links, isrc, iswc, upc in
                viewModel.updateSong(
                    id: resolvedSong.id,
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
        .fullScreenCover(isPresented: $isEditingNotes) {
            NavigationStack {
                VStack {
                    TextEditor(text: $notesText)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .scrollContentBackground(.hidden)
                        .background(Color.paletteBackground)
                }
                .background(Color.paletteBackground)
                .scrollDismissesKeyboard(.immediately)
                .keyboardDismissal()
                .navigationTitle("Edit Notes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { isEditingNotes = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewModel.updateSongNotes(id: resolvedSong.id, notes: notesText)
                            isEditingNotes = false
                        }
                    }
                }
                .onAppear {
                    notesText = resolvedSong.notes
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .alert("Playback unavailable", isPresented: $showPlaybackAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(playbackAlertMessage)
        }
        .sheet(isPresented: $showLinkPicker) {
            SingleMusicLinkPicker {
                handleLinkSelection($0)
            } onCancel: {
                showLinkPicker = false
            }
        }
    }

    private func playFromLibrary() {
        guard let persistentID = resolvedSong.mediaLibraryPersistentID else {
            playbackAlertMessage = "No library track is linked to this song."
            showPlaybackAlert = true
            return
        }
        playbackController.toggle(for: persistentID) { message in
            playbackAlertMessage = message
            showPlaybackAlert = true
        }
    }

    private func handleLinkSelection(_ payload: SongImportPayload?) {
        showLinkPicker = false
        guard let payload else { return }
        viewModel.linkSongToLibrary(id: resolvedSong.id, payload: payload)
    }

    @ViewBuilder
    private var overviewContent: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(resolvedSong.title)
                    .font(.title2.bold())
                HStack(spacing: 8) {
                    Menu {
                        ForEach(SongPhase.allCases) { phase in
                            Button {
                                viewModel.updateSongPhase(id: resolvedSong.id, phase: phase)
                            } label: {
                                if phase == resolvedSong.phase {
                                    Label(phase.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(phase.rawValue)
                                }
                            }
                        }
                    } label: {
                        PhaseTag(phase: resolvedSong.phase)
                    }
                    Tag(viewModel.profile.artistName.isEmpty ? "Enter Your Artist Name in Settings" : resolvedSong.primaryArtist)
                    if let releaseDate = resolvedSong.releaseDate {
                        Tag("Release: \(releaseDate.formatted(date: .abbreviated, time: .omitted))")
                    }
                    libraryControl
                }
            }
        }
        Section(header: Text("Registration Checklist")) {
            checklistRow("PRO", keyPath: \.pro)
            checklistRow("MLC", keyPath: \.mlc)
            checklistRow("HFA", keyPath: \.hfa)
            checklistRow("SoundExchange", keyPath: \.soundExchange)
            checklistRow("Music Reports", keyPath: \.musicReports)
            checklistRow("\(resolvedSong.distributor.displayName)", keyPath: \.distributorSubmitted)
        }

        Section(header: Text("Primary")) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Artist: \(resolvedSong.primaryArtist)")
                Text("Songwriter: \(resolvedSong.primarySongwriter)")
                    .foregroundStyle(.secondary)
                Text("PRO: \(viewModel.profile.mainPRO.rawValue)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("IPI: \(viewModel.profile.ipi)")    
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        Section(header: Text("Collaborators")) {
            if resolvedSong.collaborators.isEmpty {
                Text("No collaborators linked.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(resolvedSong.collaborators) { collaborator in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collaborator.artistName)
                        Text(collaborator.songwriterName)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        if let pro = collaborator.preferredPRO {
                            Text("PRO: \(pro.rawValue)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }

        Section(header: Text("Links")) {
            if resolvedSong.links.isEmpty {
                Text("No links added.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(resolvedSong.links.prefix(5)) { link in
                    if let url = link.url {
                        Button {
                            openURL(url)
                        } label: {
                            HStack {
                                Text(link.title)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text(link.title)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var notesContent: some View {
        Section(header: Text("Notes")) {
            if resolvedSong.notes.isEmpty {
                Text("No notes yet. Add lyrics, notes, or session ideas.")
                    .foregroundStyle(.secondary)
            } else {
                Text(resolvedSong.notes)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var libraryControl: some View {
        if let persistentID = resolvedSong.mediaLibraryPersistentID {
            Button {
                playFromLibrary()
            } label: {
                Image(systemName: playbackController.isPlaying(persistentID: persistentID) ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.borderless)
            .tint(.paletteBrick)
            .accessibilityLabel("Play imported song")
        } else {
            Button("Link to Music Library") {
                showLinkPicker = true
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private var advancedContent: some View {
        if subscriptionService.hasProAccess == false {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pro access required to view advanced details.")
                        .font(.headline)
                    Text("Unlock splits, contributions, and identifiers.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button(action: { showPaywall = true }) {
                        Text("Get Pro Access")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 4)
            }
        } else {
            Section(header: Text("Splits")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Primary")
                        .font(.subheadline.weight(.semibold))
                    Text("Master: \(Int(resolvedSong.primarySplits.master))% · Publishing: \(Int(resolvedSong.primarySplits.publishing))%")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                ForEach(resolvedSong.collaborators) { collaborator in
                    let allocation = resolvedSong.collaboratorSplits[collaborator.id] ?? .zero
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collaborator.artistName)
                            .font(.subheadline.weight(.semibold))
                        Text("Master: \(Int(allocation.master))% · Publishing: \(Int(allocation.publishing))%")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section(header: Text("Contributions")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Primary")
                        .font(.subheadline.weight(.semibold))
                    Text(contributionList(resolvedSong.primaryContributions))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                ForEach(resolvedSong.collaborators) { collaborator in
                    let contributions = resolvedSong.collaboratorContributions[collaborator.id] ?? []
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collaborator.artistName)
                            .font(.subheadline.weight(.semibold))
                        Text(contributionList(contributions))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section(header: Text("Identifiers")) {
                Text("ISRC: \(resolvedSong.isrc ?? "—")")
                Text("ISWC: \(resolvedSong.iswc ?? "—")")
                Text("UPC: \(resolvedSong.upc ?? "—")")
            }
        }
    }

    private func checklistRow(_ title: String, keyPath: WritableKeyPath<RegistrationChecklist, Bool>) -> some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: Binding(
                get: { currentChecklist[keyPath: keyPath] },
                set: { _ in viewModel.toggleChecklist(for: song.id, keyPath: keyPath) }
            ))
            .labelsHidden()
        }
    }

    private var currentChecklist: RegistrationChecklist {
        viewModel.songs.first(where: { $0.id == song.id })?.checklist ?? song.checklist
    }

    private var resolvedSong: Song {
        viewModel.songs.first(where: { $0.id == song.id }) ?? song
    }

    private func contributionList(_ contributions: Set<Contribution>) -> String {
        if contributions.isEmpty { return "None" }
        let sorted = contributions.sorted { $0.displayName < $1.displayName }
        return sorted.map { $0.displayName }.joined(separator: ", ")
    }

}

private enum DetailTab: String, CaseIterable, Identifiable {
    case overview
    case notes
    case advanced

    var id: String { rawValue }
    var label: String {
        switch self {
        case .overview: return "Overview"
        case .notes: return "Notes"
        case .advanced: return "Advanced"
        }
    }
}

private struct Tag: View {
    var text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.paletteSurface)
            .clipShape(Capsule())
    }
}
