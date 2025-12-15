import SwiftUI

struct AppShellView: View {
    @StateObject private var viewModel: AppStateViewModel
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled: Bool = false

    @MainActor
    init(viewModel: AppStateViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.paletteBackground
                .ignoresSafeArea()

            TabView {
                SongsHomeView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Songs", systemImage: "music.note.list")
                    }

                CollaboratorsView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Collaborators", systemImage: "person.2")
                    }

                SettingsView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .tint(.paletteBrick)
        }
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
    }
}
