import Foundation

enum PRO: String, CaseIterable, Identifiable {
    case bmi = "BMI"
    case ascap = "ASCAP"
    case sesac = "SESAC"

    var id: String { rawValue }
}

enum SongPhase: String, CaseIterable, Identifiable {
    case pending = "Pending"
    case writing = "Writing"
    case recording = "Recording"
    case mixing = "Mixing"
    case mastering = "Mastering"
    case completed = "Completed"

    var id: String { rawValue }
}

enum DistributorPreset: String, CaseIterable, Identifiable {
    case cdBaby = "CD Baby"
    case distrokid = "Distrokid"
    case tunecore = "Tunecore"
    case tooLost = "Too Lost"
    case unitedMasters = "United Masters"
    case amuse = "Amuse"
    case other = "Other"

    var id: String { rawValue }
}

struct Distributor: Equatable, Hashable {
    var preset: DistributorPreset
    var customName: String?

    var displayName: String {
        switch preset {
        case .other:
            return (customName?.isEmpty == false ? customName : nil) ?? "Other"
        default:
            return preset.rawValue
        }
    }
}

enum Contribution: String, CaseIterable, Identifiable, Hashable {
    case lyricist
    case composer
    case songwriter
    case topliner
    case arranger
    case leadVocalist
    case featuredArtist
    case backgroundVocalist
    case sessionVocalist
    case instrumentalist
    case sessionMusician
    case producer
    case coProducer
    case beatmaker
    case musicProgrammer
    case soundDesigner
    case additionalProducer
    case recordingEngineer
    case mixingEngineer
    case masteringEngineer
    case vocalEngineer
    case assistantEngineer

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lyricist: return "Lyricist"
        case .composer: return "Composer"
        case .songwriter: return "Songwriter"
        case .topliner: return "Topliner"
        case .arranger: return "Arranger"
        case .leadVocalist: return "Lead Vocalist"
        case .featuredArtist: return "Featured Artist"
        case .backgroundVocalist: return "Background Vocalist"
        case .sessionVocalist: return "Session Vocalist"
        case .instrumentalist: return "Instrumentalist"
        case .sessionMusician: return "Session Musician"
        case .producer: return "Producer"
        case .coProducer: return "Co-Producer"
        case .beatmaker: return "Beatmaker"
        case .musicProgrammer: return "Music Programmer"
        case .soundDesigner: return "Sound Designer"
        case .additionalProducer: return "Additional Producer"
        case .recordingEngineer: return "Recording Engineer"
        case .mixingEngineer: return "Mixing Engineer"
        case .masteringEngineer: return "Mastering Engineer"
        case .vocalEngineer: return "Vocal Engineer"
        case .assistantEngineer: return "Assistant Engineer"
        }
    }

    var category: Int {
        switch self {
        case .lyricist, .composer, .songwriter, .topliner, .arranger: return 1
        case .leadVocalist, .featuredArtist, .backgroundVocalist, .sessionVocalist, .instrumentalist, .sessionMusician: return 2
        case .producer, .coProducer, .beatmaker, .musicProgrammer, .soundDesigner, .additionalProducer: return 3
        case .recordingEngineer, .mixingEngineer, .masteringEngineer, .vocalEngineer, .assistantEngineer: return 4
        }
    }
}

struct RegistrationChecklist: Hashable {
    var pro: Bool
    var mlc: Bool
    var hfa: Bool
    var soundExchange: Bool
    var musicReports: Bool
    var distributorSubmitted: Bool

    static let empty = RegistrationChecklist(pro: false, mlc: false, hfa: false, soundExchange: false, musicReports: false, distributorSubmitted: false)

    var completedCount: Int {
        [pro, mlc, hfa, soundExchange, musicReports, distributorSubmitted].filter { $0 }.count
    }

    var total: Int { 6 }
    var progressLabel: String { "\(completedCount)/\(total)" }
}

struct UserProfile {
    var artistName: String
    var songwriterName: String
    var mainPRO: PRO
    var distributor: Distributor
    var ipi: String
    var defaultContributions: Set<Contribution>
    var hasCompletedOnboarding: Bool
}

struct Collaborator: Identifiable, Hashable {
    let id: UUID
    var artistName: String
    var songwriterName: String
    var preferredPRO: PRO?
    var defaultContributions: Set<Contribution>
    var ipi: String?

    init(id: UUID = UUID(), artistName: String, songwriterName: String, preferredPRO: PRO? = nil, defaultContributions: Set<Contribution> = [], ipi: String? = nil) {
        self.id = id
        self.artistName = artistName
        self.songwriterName = songwriterName
        self.preferredPRO = preferredPRO
        self.defaultContributions = defaultContributions
        self.ipi = ipi
    }
}

struct Song: Identifiable, Hashable {
    let id: UUID
    var title: String
    let createdAt: Date
    var releaseDate: Date?
    var phase: SongPhase
    var mediaLibraryPersistentID: UInt64?
    var primaryArtist: String
    var primarySongwriter: String
    var notes: String
    var collaborators: [Collaborator]
    var links: [SongLink]
    var distributor: Distributor
    var checklist: RegistrationChecklist
    var primarySplits: SplitAllocation
    var collaboratorSplits: [UUID: SplitAllocation]
    var primaryContributions: Set<Contribution>
    var collaboratorContributions: [UUID: Set<Contribution>]
    var isrc: String?
    var iswc: String?
    var upc: String?

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        releaseDate: Date? = nil,
        phase: SongPhase,
        mediaLibraryPersistentID: UInt64? = nil,
        primaryArtist: String,
        primarySongwriter: String,
        notes: String = "",
        collaborators: [Collaborator] = [],
        links: [SongLink] = [],
        distributor: Distributor,
        checklist: RegistrationChecklist = .empty,
        primarySplits: SplitAllocation = .full,
        collaboratorSplits: [UUID: SplitAllocation] = [:],
        primaryContributions: Set<Contribution> = [],
        collaboratorContributions: [UUID: Set<Contribution>] = [:],
        isrc: String? = nil,
        iswc: String? = nil,
        upc: String? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.releaseDate = releaseDate
        self.phase = phase
        self.mediaLibraryPersistentID = mediaLibraryPersistentID
        self.primaryArtist = primaryArtist
        self.primarySongwriter = primarySongwriter
        self.notes = notes
        self.collaborators = collaborators
        self.links = links
        self.distributor = distributor
        self.checklist = checklist
        self.primarySplits = primarySplits
        self.collaboratorSplits = collaboratorSplits
        self.primaryContributions = primaryContributions
        self.collaboratorContributions = collaboratorContributions
        self.isrc = isrc
        self.iswc = iswc
        self.upc = upc
    }
}

struct SongLink: Identifiable, Hashable {
    let id: UUID
    var title: String
    var urlString: String

    init(id: UUID = UUID(), title: String, urlString: String) {
        self.id = id
        self.title = title
        self.urlString = urlString
    }

    var url: URL? {
        URL(string: urlString)
    }
}

struct SplitAllocation: Hashable {
    var master: Double
    var publishing: Double

    static let full = SplitAllocation(master: 100, publishing: 100)
    static let zero = SplitAllocation(master: 0, publishing: 0)
}

enum FreeTierLimits {
    static let songs = 100
    static let collaborators = 3
}
