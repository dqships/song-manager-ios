import Foundation

enum SiriPercentageFormatter {
    nonisolated static func string(from value: Double) -> String {
        if value.rounded() == value { return String(Int(value)) }
        return String(format: "%.2f", value).replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
    }
}
