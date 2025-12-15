import Foundation

enum EducationContent {
    static let topics: [EducationTopic] =
        EducationTopicsCore.topics +
        EducationTopicsCollaboration.topics +
        EducationTopicsRelease.topics +
        EducationTopicsStrategy.topics

    static let startHerePath = EducationPath(
        id: "start-here",
        title: "Start Here",
        description: "Recommended order to understand rights, money, collaboration, and release steps.",
        topicIDs: [
            "glossary",
            "ownership-rights",
            "royalties",
            "organizations",
            "collaborators",
            "splits-and-credits",
            "release-lifecycle",
            "common-mistakes",
            "distributors",
            "decision-trees",
            "archetypes",
            "growth",
            "monetization-paths"
        ]
    )

    static let quickJumpPaths: [EducationPath] = [
        EducationPath(
            id: "release-checklist",
            title: "About to Release",
            description: "Checklists and pitfalls before you set a date.",
            topicIDs: ["release-lifecycle", "splits-and-credits", "common-mistakes"]
        ),
        EducationPath(
            id: "royalties-basics",
            title: "Royalties & Who Pays",
            description: "Understand the money flows and who collects it.",
            topicIDs: ["royalties", "organizations", "glossary"]
        ),
        EducationPath(
            id: "collaboration-guardrails",
            title: "Collaboration Guardrails",
            description: "Roles, splits, and agreements that prevent disputes.",
            topicIDs: ["collaborators", "splits-and-credits", "ownership-rights"]
        ),
        EducationPath(
            id: "growth-choices",
            title: "Growth & Monetization",
            description: "Pick a lane for growth and revenue beyond streams.",
            topicIDs: ["archetypes", "growth", "monetization-paths"]
        )
    ]

    static func topic(id: String) -> EducationTopic? {
        topics.first { $0.id == id }
    }
}
