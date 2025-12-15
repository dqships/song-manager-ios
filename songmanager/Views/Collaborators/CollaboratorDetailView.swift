import SwiftUI

struct CollaboratorDetailView: View {
    @EnvironmentObject var viewModel: AppStateViewModel
    let collaborator: Collaborator
    let onEdit: () -> Void

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(collaborator.artistName)
                        .font(.title2.bold())
                    Text(collaborator.songwriterName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let pro = collaborator.preferredPRO {
                        Text("PRO: \(pro.rawValue)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    if !collaborator.defaultContributions.isEmpty {
                        Text("Default: \(contributionList(collaborator.defaultContributions))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    if let ipi = collaborator.ipi, !ipi.isEmpty {
                        Text("IPI: \(ipi)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section(header: Text("Linked Songs")) {
                let songs = viewModel.songs.filter { song in
                    song.collaborators.contains(where: { $0.id == collaborator.id })
                }
                if songs.isEmpty {
                    Text("Not linked to any songs.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(songs) { song in
                        NavigationLink {
                            SongDetailView(song: song)
                                .environmentObject(viewModel)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(song.title)
                                Text(song.phase.rawValue)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Collaborator")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { onEdit() }
            }
        }
    }

    private func contributionList(_ contributions: Set<Contribution>) -> String {
        if contributions.isEmpty { return "None" }
        return contributions
            .sorted { $0.displayName < $1.displayName }
            .map { $0.displayName }
            .joined(separator: ", ")
    }
}

#Preview {
    let viewModel = AppStateViewModel.preview()
    CollaboratorDetailView(collaborator: viewModel.collaborators.first ?? Collaborator(artistName: "Preview", songwriterName: "Preview"), onEdit: {})
        .environmentObject(viewModel)
}
