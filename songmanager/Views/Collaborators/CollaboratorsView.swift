import SwiftUI
import RevenueCatUI

struct CollaboratorsView: View {
    @EnvironmentObject var viewModel: AppStateViewModel
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var isAddingCollaborator = false
    @State private var collaboratorToEdit: Collaborator? = nil
    @State private var draftArtistName = ""
    @State private var draftSongwriterName = ""
    @State private var draftPRO: PRO? = nil
    @State private var draftContributions: Set<Contribution> = []
    @State private var draftIPI: String = ""
    @State private var toastMessage: String?
    @State private var showPaywall = false
    @State private var pendingPaywallFromForm = false

    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    Section(header: Text("Collaborators")) {
                        if viewModel.collaborators.isEmpty {
                            Text("Add collaborators to link them to songs.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.collaborators) { collaborator in
                                NavigationLink {
                                    CollaboratorDetailView(collaborator: collaborator, onEdit: {
                                        startEditing(collaborator)
                                    })
                                    .environmentObject(viewModel)
                                } label: {
                                    collaboratorRow(collaborator)
                                }
                            }
                            .onDelete { offsets in
                                let ids = offsets.map { viewModel.collaborators[$0].id }
                                viewModel.deleteCollaborators(ids: ids)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .background(Color.paletteBackground)
                .navigationTitle("Collaborators")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            openNewCollaboratorForm()
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isAddingCollaborator, onDismiss: {
                    if pendingPaywallFromForm {
                        presentPaywall()
                        pendingPaywallFromForm = false
                    }
                }) {
                    NavigationStack {
                        Form {
                            Section(header: Text("Names")) {
                                TextField("Artist name", text: $draftArtistName)
                                    .textInputAutocapitalization(.words)
                                TextField("Songwriter name", text: $draftSongwriterName)
                                    .textInputAutocapitalization(.words)
                            }

                            Section(header: Text("Preferred PRO (optional)")) {
                                Picker("Preferred PRO", selection: Binding(
                                    get: { draftPRO ?? PRO.ascap },
                                    set: { draftPRO = $0 }
                                )) {
                                    ForEach(PRO.allCases) { pro in
                                        Text(pro.rawValue).tag(pro)
                                    }
                                }
                                .pickerStyle(.segmented)
                                Toggle("No preference", isOn: Binding(
                                    get: { draftPRO == nil },
                                    set: { isOn in
                                        draftPRO = isOn ? nil : PRO.ascap
                                    }
                                ))
                            }

                            Section(header: Text("IPI (optional)")) {
                                TextField("IPI number", text: $draftIPI)
                                    .keyboardType(.numberPad)
                                Text("Used for PRO registrations.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                        Section(header: Text("Default Contributions (types 1–3)")) {
                            if subscriptionService.hasProAccess {
                                contributionGrid(selection: $draftContributions)
                                Text("Applied automatically when you link this collaborator to a song. You can still adjust per song.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            } else {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Pro needed to set default contributions.")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Upgrade to Pro to manage collaborator defaults.")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Button("Get Pro Access") {
                                        pendingPaywallFromForm = true
                                        isAddingCollaborator = false
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                        }
                        .scrollDismissesKeyboard(.immediately)
                        .navigationTitle(collaboratorToEdit == nil ? "New Collaborator" : "Edit Collaborator")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { isAddingCollaborator = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save") { saveCollaborator() }
                                .disabled(draftArtistName.trimmingCharacters(in: .whitespaces).isEmpty || draftSongwriterName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                    }
                    .keyboardDismissal()
                }
            }
            .background(Color.paletteBackground)
            .keyboardDismissal()

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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func presentPaywall() {
        DispatchQueue.main.async {
            showPaywall = true
        }
    }

    private func openNewCollaboratorForm() {
        if subscriptionService.hasProAccess == false && viewModel.collaborators.count >= FreeTierLimits.collaborators {
            withAnimation {
                toastMessage = "Need more than \(FreeTierLimits.collaborators) collaborators? Go Pro to add more."
            }
            return
        }
        draftArtistName = ""
        draftSongwriterName = ""
        draftPRO = nil
        collaboratorToEdit = nil
        draftContributions = []
        draftIPI = ""
        isAddingCollaborator = true
    }

    private func startEditing(_ collaborator: Collaborator) {
        draftArtistName = collaborator.artistName
        draftSongwriterName = collaborator.songwriterName
        draftPRO = collaborator.preferredPRO
        draftContributions = collaborator.defaultContributions
        draftIPI = collaborator.ipi ?? ""
        collaboratorToEdit = collaborator
        isAddingCollaborator = true
    }

    private func saveCollaborator() {
        if var editing = collaboratorToEdit {
            editing.artistName = draftArtistName
            editing.songwriterName = draftSongwriterName
            editing.preferredPRO = draftPRO
            editing.defaultContributions = draftContributions
            editing.ipi = draftIPI.isEmpty ? nil : draftIPI
            viewModel.updateCollaborator(editing)
        } else {
            viewModel.addCollaborator(artistName: draftArtistName, songwriterName: draftSongwriterName, preferredPRO: draftPRO, defaultContributions: draftContributions, ipi: draftIPI.isEmpty ? nil : draftIPI)
        }
        isAddingCollaborator = false
    }

    private func collaboratorRow(_ collaborator: Collaborator) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(collaborator.artistName)
                .font(.headline)
                .foregroundColor(.primary)
            Text(collaborator.songwriterName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let pro = collaborator.preferredPRO {
                Text("PRO: \(pro.rawValue)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private func contributionGrid(selection: Binding<Set<Contribution>>) -> some View {
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
}
