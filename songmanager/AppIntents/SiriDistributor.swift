import AppIntents

enum SiriDistributor: String, AppEnum {
    case cdBaby, distrokid, tunecore, tooLost, unitedMasters, amuse, other

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Distributor")
    static let caseDisplayRepresentations: [SiriDistributor: DisplayRepresentation] = [
        .cdBaby: "CD Baby", .distrokid: "DistroKid", .tunecore: "TuneCore", .tooLost: "Too Lost", .unitedMasters: "UnitedMasters", .amuse: "Amuse", .other: "Other"
    ]

    var preset: DistributorPreset {
        switch self {
        case .cdBaby: .cdBaby
        case .distrokid: .distrokid
        case .tunecore: .tunecore
        case .tooLost: .tooLost
        case .unitedMasters: .unitedMasters
        case .amuse: .amuse
        case .other: .other
        }
    }

    nonisolated var dialogName: String {
        switch self {
        case .cdBaby: "CD Baby"
        case .distrokid: "DistroKid"
        case .tunecore: "TuneCore"
        case .tooLost: "Too Lost"
        case .unitedMasters: "UnitedMasters"
        case .amuse: "Amuse"
        case .other: "Other"
        }
    }
}
