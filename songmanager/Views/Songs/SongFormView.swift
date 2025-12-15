import SwiftUI
import RevenueCatUI

struct SongFormView: View {
    enum Mode {
        case create
        case edit(existing: Song)

        var title: String {
            switch self {
            case .create: return "New Song"
            case .edit: return "Edit Song"
            }
        }

        var primaryButtonLabel: String {
            switch self {
            case .create: return "Add Song"
            case .edit: return "Save Changes"
            }
        }
    }

    @EnvironmentObject var viewModel: AppStateViewModel
    @EnvironmentObject var subscriptionService: SubscriptionService
    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (String, SongPhase, Date?, Set<UUID>, RegistrationChecklist, [UUID: SplitAllocation], SplitAllocation, [UUID: Set<Contribution>], Set<Contribution>, [SongLink], String?, String?, String?) -> Void

    @State private var title: String
    @State private var phase: SongPhase
    @State private var hasReleaseDate: Bool
    @State private var releaseDate: Date
    @State private var selectedCollaborators: Set<UUID>
    @State private var checklist: RegistrationChecklist
    @State private var collaboratorSplits: [UUID: SplitAllocation]
    @State private var collaboratorContributions: [UUID: Set<Contribution>]
    @State private var primaryContributions: Set<Contribution>
    @State private var links: [SongLink]
    @State private var hasAppliedProfileDefaults = false
    @State private var showCollaborators = false
    @State private var showAdvanced = false
    @State private var isrc: String
    @State private var iswc: String
    @State private var upc: String
    @State private var showPaywall = false

    init(mode: Mode, onSave: @escaping (String, SongPhase, Date?, Set<UUID>, RegistrationChecklist, [UUID: SplitAllocation], SplitAllocation, [UUID: Set<Contribution>], Set<Contribution>, [SongLink], String?, String?, String?) -> Void) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .create:
            _title = State(initialValue: "")
            _phase = State(initialValue: .writing)
            _hasReleaseDate = State(initialValue: false)
            _releaseDate = State(initialValue: Date())
            _selectedCollaborators = State(initialValue: [])
            _checklist = State(initialValue: .empty)
            _collaboratorSplits = State(initialValue: [:])
            _collaboratorContributions = State(initialValue: [:])
            _primaryContributions = State(initialValue: [])
            _links = State(initialValue: [])
            _isrc = State(initialValue: "")
            _iswc = State(initialValue: "")
            _upc = State(initialValue: "")
        case .edit(let existing):
            _title = State(initialValue: existing.title)
            _phase = State(initialValue: existing.phase)
            _hasReleaseDate = State(initialValue: existing.releaseDate != nil)
            _releaseDate = State(initialValue: existing.releaseDate ?? Date())
            _selectedCollaborators = State(initialValue: Set(existing.collaborators.map { $0.id }))
            _checklist = State(initialValue: existing.checklist)
            _collaboratorSplits = State(initialValue: existing.collaboratorSplits)
            _collaboratorContributions = State(initialValue: existing.collaboratorContributions)
            _primaryContributions = State(initialValue: existing.primaryContributions)
            _links = State(initialValue: existing.links)
            _isrc = State(initialValue: existing.isrc ?? "")
            _iswc = State(initialValue: existing.iswc ?? "")
            _upc = State(initialValue: existing.upc ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Song title", text: $title)
                        .textInputAutocapitalization(.words)
                }

                Section(header: Text("Primary")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.profile.artistName.isEmpty ? "Add artist name in Settings" : viewModel.profile.artistName)
                        Text(viewModel.profile.songwriterName.isEmpty ? "Add songwriter name in Settings" : viewModel.profile.songwriterName)
                            .foregroundStyle(.secondary)
                        Label("PRO: \(viewModel.profile.mainPRO.rawValue)", systemImage: "music.quarternote.3")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(header: Text("Phase")) {
                    Picker("Phase", selection: $phase) {
                        ForEach(SongPhase.allCases) { phase in
                            Text(phase.rawValue).tag(phase)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Links")) {
                    if links.isEmpty {
                        Text("Add up to 5 links (e.g., reference mix, release page).")
                            .foregroundStyle(.secondary)
                    }
                    ForEach($links) { $link in
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Title", text: $link.title)
                            TextField("https://example.com", text: $link.urlString)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                            Button(role: .destructive) {
                                links.removeAll { $0.id == link.id }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 4)
                    }
                    Button {
                        links.append(SongLink(title: "", urlString: ""))
                    } label: {
                        Label("Add Link", systemImage: "plus")
                    }
                    .disabled(links.count >= 5)
                    if hasInvalidLinks {
                        Text("Enter a title and a valid http/https URL. Only the first 5 valid links are saved.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(header: collapsibleHeader(title: "Collaborators", isExpanded: $showCollaborators)) {
                    if showCollaborators {
                        if viewModel.collaborators.isEmpty {
                            Text("Add collaborators first to link them.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.collaborators) { collaborator in
                                Toggle(isOn: Binding(
                                    get: { selectedCollaborators.contains(collaborator.id) },
                                    set: { isOn in
                                        if isOn {
                                            selectedCollaborators.insert(collaborator.id)
                                            if collaboratorSplits[collaborator.id] == nil {
                                                collaboratorSplits[collaborator.id] = .zero
                                            }
                                            if collaboratorContributions[collaborator.id] == nil {
                                                collaboratorContributions[collaborator.id] = collaborator.defaultContributions
                                            }
                                        } else {
                                            selectedCollaborators.remove(collaborator.id)
                                            collaboratorSplits[collaborator.id] = nil
                                            collaboratorContributions[collaborator.id] = nil
                                        }
                                    }
                                )) {
                                    VStack(alignment: .leading) {
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
                    }
                }

                Section(header: collapsibleHeader(title: "Advanced", isExpanded: $showAdvanced)) {
                    if showAdvanced {
                        if subscriptionService.hasProAccess == false {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Pro access required to edit advanced details.")
                                    .font(.headline)
                                Text("Unlock release dates, splits, contributions, and identifiers.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                Button(action: { showPaywall = true }) {
                                    Text("Get Pro Access")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                Section(header: Text("Release")) {
                                    Toggle("Has release date", isOn: $hasReleaseDate)
                                    if hasReleaseDate {
                                        DatePicker("Release date", selection: $releaseDate, displayedComponents: .date)
                                    }
                                }

                                if !selectedCollaborators.isEmpty {
                                    Section(header: Text("Splits")) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Primary keeps remaining after collaborator splits.")
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                        }
                                        ForEach(Array(selectedCollaborators), id: \.self) { collaboratorID in
                                            if let collaborator = viewModel.collaborators.first(where: { $0.id == collaboratorID }) {
                                                VStack(alignment: .leading, spacing: 6) {
                                                    Text(collaborator.artistName)
                                                        .font(.subheadline.weight(.semibold))
                                                    splitRow(title: "Master", binding: bindingForSplit(collaboratorID: collaboratorID, keyPath: \.master))
                                                    splitRow(title: "Publishing", binding: bindingForSplit(collaboratorID: collaboratorID, keyPath: \.publishing))
                                                }
                                                .padding(.vertical, 4)
                                            }
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Primary after splits")
                                                .font(.footnote.weight(.semibold))
                                            Text("Master: \(Int(primarySplits.master))% · Publishing: \(Int(primarySplits.publishing))%")
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }

                                Section(header: Text("Contributions")) {
                                    contributionGrid(for: Binding(
                                        get: { primaryContributions },
                                        set: { primaryContributions = $0 }
                                    ))

                                    if !selectedCollaborators.isEmpty {
                                        ForEach(Array(selectedCollaborators), id: \.self) { collaboratorID in
                                            if let collaborator = viewModel.collaborators.first(where: { $0.id == collaboratorID }) {
                                                VStack(alignment: .leading, spacing: 6) {
                                                    Text(collaborator.artistName)
                                                        .font(.subheadline.weight(.semibold))
                                                    contributionGrid(for: Binding(
                                                        get: { collaboratorContributions[collaboratorID] ?? collaborator.defaultContributions },
                                                        set: { collaboratorContributions[collaboratorID] = $0 }
                                                    ))
                                                }
                                                .padding(.vertical, 4)
                                            }
                                        }
                                    }
                                }

                                Section(header: Text("Identifiers")) {
                                    TextField("ISRC", text: $isrc)
                                        .textInputAutocapitalization(.characters)
                                        .autocorrectionDisabled()
                                    TextField("ISWC", text: $iswc)
                                        .textInputAutocapitalization(.characters)
                                        .autocorrectionDisabled()
                                    TextField("UPC", text: $upc)
                                        .textInputAutocapitalization(.characters)
                                        .autocorrectionDisabled()
                                }
                            }
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(mode.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.primaryButtonLabel) {
                        let filteredSplits = collaboratorSplits.filter { selectedCollaborators.contains($0.key) }
                        let filteredContributions = contributionsForSave()
                        let isPro = subscriptionService.hasProAccess
                        let allowAdvanced = isPro || mode.isEdit
                        let allowedReleaseDate: Date? = {
                            guard allowAdvanced, hasReleaseDate else { return nil }
                            return releaseDate
                        }()
                        let allowedCollaboratorContributions: [UUID: Set<Contribution>] = {
                            if isPro {
                                return filteredContributions
                            } else if mode.isEdit {
                                return filteredContributions
                            } else {
                                return [:]
                            }
                        }()
                        let allowedPrimaryContributions: Set<Contribution> = {
                            if isPro { return primaryContributions }
                            return mode.isEdit ? primaryContributions : []
                        }()
                        onSave(
                            title,
                            phase,
                            allowedReleaseDate,
                            selectedCollaborators,
                            checklist,
                            allowAdvanced ? filteredSplits : [:],
                            allowAdvanced ? primarySplits : .full,
                            allowAdvanced ? allowedCollaboratorContributions : [:],
                            allowAdvanced ? allowedPrimaryContributions : [],
                            linksForSave(),
                            allowAdvanced ? (isrc.isEmpty ? nil : isrc) : (mode.isEdit ? (isrc.isEmpty ? nil : isrc) : nil),
                            allowAdvanced ? (iswc.isEmpty ? nil : iswc) : (mode.isEdit ? (iswc.isEmpty ? nil : iswc) : nil),
                            allowAdvanced ? (upc.isEmpty ? nil : upc) : (mode.isEdit ? (upc.isEmpty ? nil : upc) : nil)
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && mode.isCreate)
                }
            }
        }
        .keyboardDismissal()
        .onAppear {
            applyProfileDefaultContributionsIfNeeded()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func bindingForSplit(collaboratorID: UUID, keyPath: WritableKeyPath<SplitAllocation, Double>) -> Binding<Double> {
        Binding(
            get: {
                collaboratorSplits[collaboratorID, default: .zero][keyPath: keyPath]
            },
            set: { newValue in
                var allocation = collaboratorSplits[collaboratorID, default: .zero]
                let capped = cappedValue(newValue, for: keyPath, collaboratorID: collaboratorID)
                allocation[keyPath: keyPath] = capped
                collaboratorSplits[collaboratorID] = allocation
            }
        )
    }

    private func cappedValue(_ proposed: Double, for keyPath: WritableKeyPath<SplitAllocation, Double>, collaboratorID: UUID) -> Double {
        let otherSum = collaboratorSplits
            .filter { $0.key != collaboratorID }
            .reduce(0) { partialResult, entry in
                partialResult + entry.value[keyPath: keyPath]
            }
        let maxAllowed = max(0, 100 - otherSum)
        return min(max(proposed, 0), maxAllowed)
    }

    private var primarySplits: SplitAllocation {
        let masterSum = collaboratorSplits.reduce(0) { $0 + $1.value.master }
        let publishingSum = collaboratorSplits.reduce(0) { $0 + $1.value.publishing }
        return SplitAllocation(master: max(0, 100 - masterSum), publishing: max(0, 100 - publishingSum))
    }

    private func splitRow(title: String, binding: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Stepper(value: binding, in: 0...100, step: 1) {
                    Text("\(Int(binding.wrappedValue))%")
                }
                .labelsHidden()
            }
            TextField("\(title) %", value: binding, format: .number)
                .keyboardType(.numberPad)
                .onChange(of: binding.wrappedValue) { _, newValue in
                    let sanitized = min(max(newValue, 0), 100)
                    if sanitized != newValue {
                        binding.wrappedValue = sanitized
                    }
                }
        }
    }

    private func contributionGrid(for selection: Binding<Set<Contribution>>) -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return ForEach([1, 2, 3, 4], id: \.self) { category in
            VStack(alignment: .leading, spacing: 6) {
                Text(categoryTitle(category))
                    .font(.footnote.weight(.semibold))
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(contributions(for: category)) { contribution in
                        Toggle(isOn: Binding(
                            get: { selection.wrappedValue.contains(contribution) },
                            set: { isOn in
                                if isOn {
                                    selection.wrappedValue.insert(contribution)
                                } else {
                                    selection.wrappedValue.remove(contribution)
                                }
                            }
                        )) {
                            Text(contribution.displayName)
                                .font(.footnote)
                        }
                        .toggleStyle(.button)
                        .tint(.accentColor)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func contributions(for category: Int) -> [Contribution] {
        Contribution.allCases.filter { $0.category == category }
    }

    private func categoryTitle(_ category: Int) -> String {
        switch category {
        case 1: return "Songwriting & Composition"
        case 2: return "Performance & Vocals"
        case 3: return "Production & Creation"
        default: return "Engineering & Audio"
        }
    }

    private func contributionsForSave() -> [UUID: Set<Contribution>] {
        var results: [UUID: Set<Contribution>] = [:]
        for collaboratorID in selectedCollaborators {
            let current = collaboratorContributions[collaboratorID]
            let fallback = viewModel.collaborators.first(where: { $0.id == collaboratorID })?.defaultContributions ?? []
            results[collaboratorID] = current ?? fallback
        }
        return results
    }

    private func linksForSave() -> [SongLink] {
        links.map { link in
            SongLink(id: link.id, title: link.title.trimmingCharacters(in: .whitespacesAndNewlines), urlString: link.urlString.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    private var hasInvalidLinks: Bool {
        links.contains { isValidLink($0) == false }
    }

    private func isValidLink(_ link: SongLink) -> Bool {
        let trimmedTitle = link.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = link.urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty == false else { return false }
        guard let url = URL(string: trimmedURL), let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else { return false }
        return true
    }

    private func applyProfileDefaultContributionsIfNeeded() {
        guard mode.isCreate, hasAppliedProfileDefaults == false else { return }
        if primaryContributions.isEmpty {
            primaryContributions = viewModel.profile.defaultContributions
        }
        hasAppliedProfileDefaults = true
    }

    private func collapsibleHeader(title: String, isExpanded: Binding<Bool>) -> some View {
        Button {
            isExpanded.wrappedValue.toggle()
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func proLockedBadge(title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .foregroundStyle(Color.paletteBrick)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                Text("Get Pro access to unlock.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.paletteSurface)
        .cornerRadius(10)
    }

    private func upgradeButton() -> some View {
        Button {
            showPaywall = true
        } label: {
            Label("Get Pro", systemImage: "arrow.up.right.square")
        }
        .buttonStyle(.bordered)
    }
}

private extension SongFormView.Mode {
    var isCreate: Bool {
        if case .create = self { return true }
        return false
    }

    var isEdit: Bool { !isCreate }
}
