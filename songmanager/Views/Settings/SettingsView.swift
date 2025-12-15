import SwiftUI
import StoreKit
import UIKit
import RevenueCat
import RevenueCatUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: AppStateViewModel
    @EnvironmentObject var subscriptionService: SubscriptionService
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled: Bool = false

    @State private var artistName: String = ""
    @State private var songwriterName: String = ""
    @State private var selectedPRO: PRO = .bmi
    @State private var selectedDistributorPreset: DistributorPreset = .cdBaby
    @State private var customDistributorName: String = ""
    @State private var ipi: String = ""
    @State private var defaultContributions: Set<Contribution> = []

    @State private var showingProfileSheet = false
    @State private var showingSupportModal = false
    @State private var showingLegalSheet = false
    @State private var selectedLegalDocument: LegalDocument = .terms
    @State private var showingPaywall = false
    @State private var pendingPaywallFromProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paletteBackground
                    .ignoresSafeArea()

                List {
                    Section("Subscription") {
                        if subscriptionService.hasProAccess {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(Color.paletteBrick)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(subscriptionService.isLifetimeAccess ? "ReleaseKit Pro (Lifetime)" : "ReleaseKit Pro (\(currentPlanLabel ?? ""))")
                                            .font(.headline)
                                        Text(subscriptionService.isLifetimeAccess ? "Lifetime unlocked." : "Thanks for supporting! You have full access to all features.")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                if subscriptionService.isLifetimeAccess == false {
                                    Button {
                                        openManageSubscriptions()
                                    } label: {
                                        settingLabel(title: "Manage Subscription", systemImage: "arrow.triangle.2.circlepath")
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } else {
                            Button {
                                presentPaywallImmediately()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(Color.paletteBrick)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Get ReleaseKit Pro")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("Unlock unlimited songs, collaborators, and identifiers.")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Section("Artist Profile") {
                        Button {
                            populateFromProfile()
                            showingProfileSheet = true
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundStyle(Color.paletteBrick)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Profile & Registration")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(viewModel.profile.artistName.isEmpty ? "Artist: not set" : "Artist: \(viewModel.profile.artistName)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text("PRO: \(viewModel.profile.mainPRO.rawValue) • IPI: \(viewModel.profile.ipi)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    Section("Preferences") {
                        Toggle(isOn: $isDarkModeEnabled) {
                            settingLabel(title: "Dark Mode", systemImage: isDarkModeEnabled ? "moon.fill" : "moon")
                        }
                    }

                    Section("Resources") {
                        NavigationLink {
                            EducationLibraryView()
                        } label: {
                            settingLabel(title: "Artist Education Hub", systemImage: "book.pages")
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Section("About") {
                        Button {
                            requestReview()
                        } label: {
                            settingLabel(title: "Leave a Review", systemImage: "star.bubble")
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())

                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                showingSupportModal = true
                            }
                        } label: {
                            settingLabel(title: "Help & Support", systemImage: "questionmark.circle")
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())

                        Button {
                            showingLegalSheet = true
                            selectedLegalDocument = .terms
                        } label: {
                            settingLabel(title: "Terms & Privacy", systemImage: "doc.text")
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())

                        Button {
                            restorePurchases()
                        } label: {
                            settingLabel(title: "Restore Purchases", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                }
                .blur(radius: showingSupportModal ? 2 : 0)
                .disabled(showingSupportModal)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .background(Color.paletteBackground)

                if showingSupportModal {
                    SupportOverlay {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            showingSupportModal = false
                        }
                    }
                    .transition(.opacity)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingProfileSheet, onDismiss: {
                if pendingPaywallFromProfile {
                    presentPaywallImmediately()
                    pendingPaywallFromProfile = false
                }
            }) {
                ProfileSheet(
                    artistName: $artistName,
                    songwriterName: $songwriterName,
                    selectedPRO: $selectedPRO,
                    selectedDistributorPreset: $selectedDistributorPreset,
                    customDistributorName: $customDistributorName,
                    ipi: $ipi,
                    defaultContributions: $defaultContributions,
                    onSave: { saveProfile() },
                    onRequestPaywall: {
                        pendingPaywallFromProfile = true
                        showingProfileSheet = false
                    }
                )
            }
            .sheet(isPresented: $showingLegalSheet) {
                LegalSheet(selectedDocument: $selectedLegalDocument)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .onChange(of: showingPaywall) {
                Task { await subscriptionService.refreshStatus() }
            }
            .task {
                await subscriptionService.refreshStatus()
            }
        }
        .tint(Color.paletteBrick)
        .keyboardDismissal()
    }

    private func populateFromProfile() {
        artistName = viewModel.profile.artistName
        songwriterName = viewModel.profile.songwriterName
        selectedPRO = viewModel.profile.mainPRO
        selectedDistributorPreset = viewModel.profile.distributor.preset
        customDistributorName = viewModel.profile.distributor.customName ?? ""
        ipi = viewModel.profile.ipi
        defaultContributions = viewModel.profile.defaultContributions
    }

    private func saveProfile() {
        let distributor = Distributor(
            preset: selectedDistributorPreset,
            customName: selectedDistributorPreset == .other ? customDistributorName : nil
        )
        viewModel.updateProfile(
            artistName: artistName,
            songwriterName: songwriterName,
            mainPRO: selectedPRO,
            distributor: distributor,
            ipi: ipi,
            defaultContributions: defaultContributions
        )
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    private func openSupportEmail() {
        if let url = URL(string: "mailto:support@example.com") {
            UIApplication.shared.open(url)
        }
    }

    private func restorePurchases() {
        Task {
            do {
                _ = try await Purchases.shared.restorePurchases()
                await subscriptionService.refreshStatus()
            } catch {
                print("Restore purchases failed: \(error)")
            }
        }
    }

    private func openManageSubscriptions() {
        Task {
            do {
                try await Purchases.shared.showManageSubscriptions()
                await subscriptionService.refreshStatus()
            } catch {
                // Fallback to paywall if the native sheet fails.
                presentPaywallImmediately()
                print("Manage subscriptions failed: \(error)")
            }
        }
    }

    private func settingLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.paletteBrick)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var currentPlanLabel: String? {
        guard let id = subscriptionService.activeProductIdentifier?.lowercased() else { return nil }
        if id.contains("monthly") { return "Monthly" }
        if id.contains("year") { return "Yearly" }
        if id.contains("lifetime") { return "Lifetime" }
        return id
    }

    private func presentPaywallImmediately() {
        showingProfileSheet = false
        showingLegalSheet = false
        showingSupportModal = false
        DispatchQueue.main.async {
            showingPaywall = true
        }
    }
}

private struct ProfileSheet: View {
    @Binding var artistName: String
    @Binding var songwriterName: String
    @Binding var selectedPRO: PRO
    @Binding var selectedDistributorPreset: DistributorPreset
    @Binding var customDistributorName: String
    @Binding var ipi: String
    @Binding var defaultContributions: Set<Contribution>

    var onSave: () -> Void
    var onRequestPaywall: () -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionService: SubscriptionService

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Enter Your Name")) {
                    TextField("Artist (Stage Name)", text: $artistName)
                        .textInputAutocapitalization(.words)
                    TextField("Songwriter (Full Legal Name)", text: $songwriterName)
                        .textInputAutocapitalization(.words)
                }

                Section(header: Text("Main PRO")) {
                    Picker("PRO", selection: $selectedPRO) {
                        ForEach(PRO.allCases) { pro in
                            Text(pro.rawValue).tag(pro)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text("Songwriters can only affiliate with one PRO at a time. This applies to new songs by default.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("IPI (for PRO)")) {
                    TextField("IPI number", text: $ipi)
                        .keyboardType(.numberPad)
                    Text("Your IPI can be found on your PRO account. They assingn it to you when you register.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("Distributor")) {
                    Picker("Distributor", selection: $selectedDistributorPreset) {
                        ForEach(DistributorPreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    .pickerStyle(.menu)

                    if selectedDistributorPreset == .other {
                        TextField("Enter distributor name", text: $customDistributorName)
                            .textInputAutocapitalization(.words)
                    }

                    Text("This distributor will appear on new songs and the registration checklist.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("Default Contributions")) {
                    if subscriptionService.hasProAccess {
                        contributionGrid(selection: $defaultContributions)
                        Text("Applied to you by default on new songs. You can adjust per song.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pro needed to set default contributions.")
                                .font(.subheadline.weight(.semibold))
                            Text("Upgrade to Pro to manage your contribution presets.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Button("Get Pro Access") {
                                onRequestPaywall()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Enter Your Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .disabled(artistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || songwriterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .keyboardDismissal()
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

private struct LegalSheet: View {
    @Binding var selectedDocument: LegalDocument
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Document", selection: $selectedDocument) {
                    ForEach(LegalDocument.allCases) { document in
                        Text(document.title).tag(document)
                    }
                }
                .pickerStyle(.segmented)

                ScrollView {
                    Text(selectedDocument.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
            }
            .padding()
            .navigationTitle("Terms & Privacy")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct SupportOverlay: View {
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.paletteJasmine)

                VStack(spacing: 8) {
                    Text("Help & Support")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Need help? Contact us at:")
                        .foregroundStyle(.secondary)
                    Text("support@example.com")
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.paletteSurface)
                        .cornerRadius(10)
                        .onTapGesture {
                            if let url = URL(string: "mailto:support@example.com") {
                                UIApplication.shared.open(url)
                            }
                        }
                }

                Button(action: onClose) {
                    Text("Close")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .frame(maxWidth: 360)
            .background(Color.paletteBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 6)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStateViewModel.preview())
}
