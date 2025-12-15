import Foundation

struct EducationTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let summary: String
    let body: String
}

struct EducationPath: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let topicIDs: [String]
}
