import Foundation

struct ParserExpectation {
    let request: String
    let title: String
    let phase: SongPhase
    let artistName: String?
    let songwriterName: String?
    let contribution: Contribution?
    let masterSplit: Double?
    let publishingSplit: Double?
}

let expectations = [
    ParserExpectation(request: "Add North Star", title: "North Star", phase: .pending, artistName: nil, songwriterName: nil, contribution: nil, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song and move it to recording", title: "North Star", phase: .recording, artistName: nil, songwriterName: nil, contribution: nil, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song with Jordan Lee", title: "North Star", phase: .pending, artistName: "Jordan Lee", songwriterName: nil, contribution: nil, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song featuring Sugar", title: "North Star", phase: .pending, artistName: "Sugar", songwriterName: nil, contribution: .featuredArtist, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song featuring James Taylor who goes by Sugar", title: "North Star", phase: .pending, artistName: "Sugar", songwriterName: "James Taylor", contribution: .featuredArtist, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song featuring Sugar and give them 20 percent of the master", title: "North Star", phase: .pending, artistName: "Sugar", songwriterName: nil, contribution: .featuredArtist, masterSplit: 20, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song with Jordan Lee at 25 percent publishing", title: "North Star", phase: .pending, artistName: "Jordan Lee", songwriterName: nil, contribution: nil, masterSplit: nil, publishingSplit: 25),
    ParserExpectation(request: "Add North Star as a song with Jordan Lee at 20 percent master and 15 percent publishing", title: "North Star", phase: .pending, artistName: "Jordan Lee", songwriterName: nil, contribution: nil, masterSplit: 20, publishingSplit: 15),
    ParserExpectation(request: "Add North Star as a song featuring Sugar at 20 percent of both", title: "North Star", phase: .pending, artistName: "Sugar", songwriterName: nil, contribution: .featuredArtist, masterSplit: 20, publishingSplit: 20),
    ParserExpectation(request: "Add North Star as a song produced by Jordan Lee", title: "North Star", phase: .pending, artistName: "Jordan Lee", songwriterName: nil, contribution: .producer, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song written with Jordan Lee", title: "North Star", phase: .pending, artistName: nil, songwriterName: "Jordan Lee", contribution: .songwriter, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song mixed by Jordan Lee", title: "North Star", phase: .pending, artistName: "Jordan Lee", songwriterName: nil, contribution: .mixingEngineer, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add North Star as a song and move it to mixing", title: "North Star", phase: .mixing, artistName: nil, songwriterName: nil, contribution: nil, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add Sugar Rush as a song featuring Sugar, legal name James Taylor", title: "Sugar Rush", phase: .pending, artistName: "Sugar", songwriterName: "James Taylor", contribution: .featuredArtist, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add a song called \"Come With Me\"", title: "Come With Me", phase: .pending, artistName: nil, songwriterName: nil, contribution: nil, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(request: "Add a song called \"Come With Me\" featuring Sugar", title: "Come With Me", phase: .pending, artistName: "Sugar", songwriterName: nil, contribution: .featuredArtist, masterSplit: nil, publishingSplit: nil),
    ParserExpectation(
        request: "Add Walk It Like I Talk It as a song in ReleaseKit with me as the primary artist feature my buddy James Taylor who goes by Sugar and he gets 20% of the record",
        title: "Walk It Like I Talk It",
        phase: .pending,
        artistName: "Sugar",
        songwriterName: "James Taylor",
        contribution: .featuredArtist,
        masterSplit: 20,
        publishingSplit: nil
    )
]

for expectation in expectations {
    let parsed: SiriParsedSongDescription
    do {
        parsed = try SiriSongDescriptionParser.parse(expectation.request)
    } catch {
        preconditionFailure("Unexpected parse error for: \(expectation.request). Error: \(error)")
    }
    precondition(parsed.title == expectation.title, "Title mismatch for: \(expectation.request). Got: \(parsed.title)")
    precondition(parsed.phase == expectation.phase, "Phase mismatch for: \(expectation.request)")
    precondition(parsed.collaborator?.artistName == expectation.artistName, "Artist mismatch for: \(expectation.request). Got: \(String(describing: parsed.collaborator?.artistName))")
    precondition(parsed.collaborator?.songwriterName == expectation.songwriterName, "Songwriter mismatch for: \(expectation.request). Got: \(String(describing: parsed.collaborator?.songwriterName))")
    precondition(parsed.contribution == expectation.contribution, "Contribution mismatch for: \(expectation.request)")
    precondition(parsed.splits.master == expectation.masterSplit, "Master split mismatch for: \(expectation.request). Got: \(String(describing: parsed.splits.master))")
    precondition(parsed.splits.publishing == expectation.publishingSplit, "Publishing split mismatch for: \(expectation.request). Got: \(String(describing: parsed.splits.publishing))")
}

let ambiguous = try SiriSongDescriptionParser.parse("Add North Star as a song with Jordan Lee at 20 percent")
precondition(ambiguous.splits.ambiguous == 20)

do {
    _ = try SiriSongDescriptionParser.parse("Add North Star at 20 percent master")
    preconditionFailure("A split without a collaborator should fail.")
} catch SiriDataError.collaboratorRequiredForCredits {
}

for request in ["Add Come With Me", "Add I Am Featuring You", "Add Dancing With Jordan", "Add Written By the Sea", "Add North Star and Move It To Recording"] {
    do {
        _ = try SiriSongDescriptionParser.parse(request)
        preconditionFailure("An ambiguous title marker should fail: \(request)")
    } catch SiriDataError.unsupportedSongDescription {
    }
}

print("Siri parser tests passed: \(expectations.count + 7)")
