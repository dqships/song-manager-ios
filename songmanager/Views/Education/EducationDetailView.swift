import SwiftUI

struct EducationDetailView: View {
    let topic: EducationTopic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CategoryPill(text: topic.category)
                VStack(alignment: .leading, spacing: 8) {
                    Text(topic.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    summaryCard
                }
                EducationMarkdownView(text: topic.body)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.paletteBackground)
    }
}

private extension EducationDetailView {
    var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Text(topic.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.paletteSurface)
        )
    }
}

private struct EducationMarkdownView: View {
    let text: String

    private enum MarkdownBlock: Identifiable {
        case heading(String)
        case paragraph(String)
        case bulleted([String])
        case numbered([String])

        var id: String {
            switch self {
            case let .heading(value):
                return "heading-\(value)"
            case let .paragraph(value):
                return "paragraph-\(value.prefix(30))"
            case let .bulleted(values):
                return "bulleted-\(values.joined())"
            case let .numbered(values):
                return "numbered-\(values.joined())"
            }
        }
    }

    var body: some View {
        let blocks = parseBlocks(from: text)

        return VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(blocks.enumerated()), id: \.element.id) { index, block in
                if case .heading = block, index != 0 {
                    Divider()
                        .padding(.vertical, 4)
                }
                switch block {
                case let .heading(value):
                    Text(value)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, index == 0 ? 0 : 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case let .paragraph(value):
                    Text(value)
                        .font(.body)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case let .bulleted(items):
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .padding(.top, 2)
                                Text(item)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Bullet \(index + 1): \(item)")
                        }
                    }
                    .padding(.leading, 2)
                case let .numbered(items):
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .padding(.top, 2)
                                Text(item)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Step \(index + 1): \(item)")
                        }
                    }
                    .padding(.leading, 2)
                }
            }
        }
    }

    private func parseBlocks(from text: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        var paragraphLines: [String] = []
        var bulletItems: [String] = []
        var numberedItems: [String] = []

        func flushParagraph() {
            guard paragraphLines.isEmpty == false else { return }
            blocks.append(.paragraph(paragraphLines.joined(separator: " ")))
            paragraphLines.removeAll()
        }

        func flushBullets() {
            guard bulletItems.isEmpty == false else { return }
            blocks.append(.bulleted(bulletItems))
            bulletItems.removeAll()
        }

        func flushNumbers() {
            guard numberedItems.isEmpty == false else { return }
            blocks.append(.numbered(numberedItems))
            numberedItems.removeAll()
        }

        let lines = text.components(separatedBy: .newlines)
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            if line.isEmpty {
                flushParagraph()
                flushBullets()
                flushNumbers()
                continue
            }

            if isHeadingCandidate(line) && paragraphLines.isEmpty && bulletItems.isEmpty && numberedItems.isEmpty {
                blocks.append(.heading(line))
                continue
            }

            if line.hasPrefix("- ") {
                flushParagraph()
                flushNumbers()
                bulletItems.append(stripBullet(line))
                continue
            }

            if isNumbered(line) {
                flushParagraph()
                flushBullets()
                numberedItems.append(stripNumbered(line))
                continue
            }

            if numberedItems.isEmpty == false {
                numberedItems[numberedItems.count - 1] += " \(line)"
                continue
            }

            if bulletItems.isEmpty == false {
                bulletItems[bulletItems.count - 1] += " \(line)"
                continue
            }

            paragraphLines.append(line)
        }

        flushParagraph()
        flushBullets()
        flushNumbers()
        return blocks
    }

    private func stripBullet(_ line: String) -> String {
        String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
    }

    private func isNumbered(_ line: String) -> Bool {
        line.range(of: #"^\d+[\)\.]\s+"#, options: .regularExpression) != nil
    }

    private func stripNumbered(_ line: String) -> String {
        guard let range = line.range(of: #"^\d+[\)\.]\s+"#, options: .regularExpression) else {
            return line
        }
        return line.replacingCharacters(in: range, with: "").trimmingCharacters(in: .whitespaces)
    }

    private func isHeadingCandidate(_ line: String) -> Bool {
        guard line.count <= 80 else { return false }
        let wordCount = line.split(separator: " ").count
        guard wordCount <= 12 else { return false }
        guard line.hasPrefix("-") == false else { return false }
        guard line.range(of: #"^\d+[\)\.]"#, options: .regularExpression) == nil else { return false }
        return line.contains(".") == false
    }
}

#Preview {
    NavigationStack {
        EducationDetailView(
            topic: EducationContent.topics.first!
        )
    }
}
