import AppIntents

enum SiriPRO: String, AppEnum {
    case ascap, bmi, sesac

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Performance rights organization")
    static let caseDisplayRepresentations: [SiriPRO: DisplayRepresentation] = [.ascap: "ASCAP", .bmi: "BMI", .sesac: "SESAC"]

    var pro: PRO { PRO(rawValue: rawValue.uppercased()) ?? .ascap }
}
