import SwiftUI

struct EducationLibraryView: View {
    @State private var searchText: String = ""

    private let topics: [EducationTopic] = EducationContent.topics

    private var filteredTopics: [EducationTopic] {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return topics
        }
        let query = searchText.lowercased()
        return topics.filter { topic in
            topic.title.lowercased().contains(query) ||
            topic.summary.lowercased().contains(query) ||
            topic.body.lowercased().contains(query)
        }
    }

    var body: some View {
        List {
            Section("All Topics") {
                ForEach(filteredTopics) { topic in
                    NavigationLink {
                        EducationDetailView(topic: topic)
                    } label: {
                        EducationTopicRow(topic: topic)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.paletteBackground)
        .navigationTitle("Education")
        .searchable(text: $searchText, prompt: "Search topics")
        .scrollDismissesKeyboard(.immediately)
        .keyboardDismissal()
        .background(Color.paletteBackground)
    }
}

private struct EducationTopicRow: View {
    let topic: EducationTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(topic.title)
                    .font(.headline)
                Spacer()
                CategoryPill(text: topic.category)
            }
            Text(topic.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CategoryPill: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.paletteSurface)
            .cornerRadius(8)
    }
}
