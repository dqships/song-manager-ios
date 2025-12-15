import SwiftUI
import MediaPlayer
import UIKit

struct OnboardingFlowView: View {
    @ObservedObject var viewModel: AppStateViewModel

    @State private var step: Step = .welcome
    @State private var artistName: String = ""
    @State private var songwriterName: String = ""
    @State private var selectedPRO: PRO = .ascap
    @State private var distributorPreset: DistributorPreset = .distrokid
    @State private var customDistributorName: String = ""
    @State private var ipi: String = ""

    @State private var showMusicPicker = false
    @State private var showMusicDeniedAlert = false
    @State private var showLimitAlert = false
    @State private var pendingImports: [SongImportPayload] = []
    @State private var limitSelectionCount: Int = 0
    @State private var lastImportSummary: String?
    @State private var hasBootstrapped = false

    var body: some View {
        ZStack {
            Color.paletteBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                header
                content
                footer
            }
            .padding(20)
        }
        .keyboardDismissal()
        .sheet(isPresented: $showMusicPicker) {
            MusicImportPicker {
                handlePickedPayloads($0)
            } onCancel: {
                showMusicPicker = false
            }
            .ignoresSafeArea()
        }
        .alert("Music Library Access Needed", isPresented: $showMusicDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Allow library access so we can import song titles for your catalog.")
        }
        .alert("Import limit is \(SongImportService.importLimit)", isPresented: $showLimitAlert) {
            Button("Import first \(SongImportService.importLimit)") {
                performImport(Array(pendingImports.prefix(SongImportService.importLimit)), forcedLimitNotice: true)
                pendingImports = []
            }
            Button("Reselect", role: .cancel) {
                pendingImports = []
            }
        } message: {
            Text("You selected \(limitSelectionCount) songs. Choose whether to import the first \(SongImportService.importLimit) or reselect.")
        }
        .onAppear {
            bootstrapProfile()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(step.title)
                .font(.largeTitle.weight(.bold))
            ProgressView(value: Double(step.index + 1), total: Double(Step.allCases.count))
                .tint(.paletteBrick)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .welcome:
            welcomeContent
        case .names:
            namesContent
        case .proIntro:
            proIntroContent
        case .proSelect:
            proSelectionContent
        case .importMusic:
            importContent
        case .success:
            successContent
        }
    }

    private var welcomeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("We’ll set up your profile and import songs from your music library so you can get started quickly.")
                .font(.title3.weight(.semibold))
            VStack(alignment: .leading, spacing: 10) {
                labelRow(systemImage: "person.text.rectangle", title: "Name", detail: "Set your artist and songwriter names.")
                labelRow(systemImage: "building.2", title: "PRO & Distributor", detail: "Pick your PRO, add an IPI, and choose your distributor.")
                labelRow(systemImage: "music.note.list", title: "Import Songs", detail: "Pull up to \(SongImportService.importLimit) songs from Apple Music.")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.paletteSurface)
        .cornerRadius(14)
    }

    private var namesContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Royalty reporting requires both your stage name and full legal name.")
                .foregroundStyle(.secondary)
            VStack(spacing: 14) {
                TextField("Artist (Stage Name)", text: $artistName)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(Color.paletteSurface)
                    .cornerRadius(12)
                TextField("Songwriter (Full Legal Name)", text: $songwriterName)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(Color.paletteSurface)
                    .cornerRadius(12)
            }
        }
    }

    private var proIntroContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What are PROs and distributors?")
                .font(.headline)
            Text("Performance Rights Organizations (PROs) like ASCAP, BMI, and SESAC collect performance royalties when your music is played publicly (radio, TV, live performances, etc.).")
                .foregroundStyle(.secondary)
            Text("Distributors like DistroKid, TuneCore, and CD Baby deliver your music to streaming platforms and help with ISRCs/UPCs.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var proSelectionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose your PRO and Distributor")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                Text("PRO")
                    .font(.subheadline.weight(.semibold))
                Picker("PRO", selection: $selectedPRO) {
                    ForEach(PRO.allCases) { pro in
                        Text(pro.rawValue).tag(pro)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 6) {
                    Text("IPI (Optional)")
                        .font(.subheadline.weight(.semibold))
                    TextField("IPI number", text: $ipi)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.paletteSurface)
                        .cornerRadius(10)
                    Text("Add your IPI now to keep it attached to new songs by default.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Distributor")
                    .font(.subheadline.weight(.semibold))
                Picker("Distributor", selection: $distributorPreset) {
                    ForEach(DistributorPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.menu)

                if distributorPreset == .other {
                    TextField("Custom distributor", text: $customDistributorName)
                        .textInputAutocapitalization(.words)
                        .padding()
                        .background(Color.paletteSurface)
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 6) {
                    labelRow(systemImage: "music.note", title: "ASCAP", detail: "Nonprofit, songwriter-friendly for the United States.")
                    labelRow(systemImage: "music.quarternote.3", title: "BMI", detail: "Nonprofit, widely used for the United States.")
                    labelRow(systemImage: "waveform.path.ecg", title: "SESAC", detail: "Invite-only, smaller network, for-profit.")
                }
                .padding(.top, 4)
            }
        }
    }

    private var importContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import from Apple Music")
                .font(.headline)
            Text("Pick up to \(SongImportService.importLimit) songs to get started quickly. Your music stays private and never leaves your device.")
                .foregroundStyle(.secondary)

            Button(action: requestMusicAccess) {
                HStack {
                    Image(systemName: "music.note.list")
                    Text("Import from Music Library")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(Color.paletteBrick.opacity(0.12))
                .foregroundColor(.paletteBlood)
                .cornerRadius(12)
            }

            Button("Skip for now") {
                step = .success
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)

            if let lastImportSummary {
                Text(lastImportSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.paletteSurface)
                    .cornerRadius(12)
            }
        }
    }

    private var successContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("You’re set.")
                .font(.title2.weight(.bold))
            Text("Profile saved. New songs will use your names, PRO, distributor, and IPI by default.")
                .foregroundStyle(.secondary)
            if let lastImportSummary {
                Text(lastImportSummary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.paletteSurface)
                    .cornerRadius(12)
            }
            Text("Tap below to jump into your catalog and start adding details, splits, and registrations.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var footer: some View {
        switch step {
        case .importMusic:
            EmptyView()
        default:
            VStack(spacing: 12) {
                Button(primaryButtonTitle) {
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .tint(.paletteBrick)
                .disabled(isPrimaryDisabled)
            }
        }
    }

    private var primaryButtonTitle: String {
        switch step {
        case .welcome: return "Get Started"
        case .names: return "Continue"
        case .proIntro: return "Continue"
        case .proSelect: return "Save & Continue"
        case .importMusic: return "Continue"
        case .success: return "Finish"
        }
    }

    private var isPrimaryDisabled: Bool {
        switch step {
        case .names, .proSelect:
            return trimmedArtistName.isEmpty || trimmedSongwriterName.isEmpty
        default:
            return false
        }
    }

    private func advance() {
        switch step {
        case .welcome:
            step = .names
        case .names:
            step = .proIntro
        case .proIntro:
            step = .proSelect
        case .proSelect:
            persistProfile(isFinal: false)
            step = .importMusic
        case .importMusic:
            step = .success
        case .success:
            completeOnboarding()
        }
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
            lastImportSummary = "No song titles were imported."
            step = .success
            return
        }

        if normalized.count > SongImportService.importLimit {
            pendingImports = normalized
            limitSelectionCount = normalized.count
            showLimitAlert = true
        } else {
            performImport(normalized)
        }
    }

    private func performImport(_ payloads: [SongImportPayload], forcedLimitNotice: Bool = false) {
        persistProfile(isFinal: false)
        let result = viewModel.importSongs(payloads)
        let imported = result.importedCount
        let skipped = result.skippedExistingTitles
        var message = "Imported \(imported) song\(imported == 1 ? "" : "s")."
        if forcedLimitNotice || result.limitedByCap {
            message.append(" Limited to \(SongImportService.importLimit) per import.")
        }
        if skipped.isEmpty == false {
            message.append(" Skipped \(skipped.count) existing title\(skipped.count == 1 ? "" : "s").")
        }
        lastImportSummary = message
        step = .success
    }

    private func completeOnboarding() {
        persistProfile(isFinal: true)
    }

    private func persistProfile(isFinal: Bool) {
        let distributor = Distributor(
            preset: distributorPreset,
            customName: distributorPreset == .other ? customDistributorName : nil
        )
        viewModel.updateProfile(
            artistName: trimmedArtistName,
            songwriterName: trimmedSongwriterName,
            mainPRO: selectedPRO,
            distributor: distributor,
            ipi: ipi.trimmingCharacters(in: .whitespacesAndNewlines),
            defaultContributions: viewModel.profile.defaultContributions,
            completeOnboarding: isFinal
        )
    }

    private func bootstrapProfile() {
        guard hasBootstrapped == false else { return }
        artistName = viewModel.profile.artistName
        songwriterName = viewModel.profile.songwriterName
        selectedPRO = viewModel.profile.mainPRO
        distributorPreset = viewModel.profile.distributor.preset
        customDistributorName = viewModel.profile.distributor.customName ?? ""
        ipi = viewModel.profile.ipi
        hasBootstrapped = true
    }

    private var trimmedArtistName: String {
        artistName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedSongwriterName: String {
        songwriterName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func labelRow(systemImage: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.paletteBrick)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private enum Step: Int, CaseIterable {
        case welcome
        case names
        case proIntro
        case proSelect
        case importMusic
        case success

        var index: Int { rawValue }

        var title: String {
            switch self {
            case .welcome: return "Welcome"
            case .names: return "Your Names"
            case .proIntro: return "PROs & Distributors"
            case .proSelect: return "Set Your Details"
            case .importMusic: return "Import Songs"
            case .success: return "All Set"
            }
        }
    }
}
