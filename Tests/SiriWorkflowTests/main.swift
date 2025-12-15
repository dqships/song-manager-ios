import Foundation

@main
struct SiriWorkflowTests {
    static func main() {
        let original: Set<Contribution> = [.songwriter, .producer]
        precondition(SiriRoleSet.applying([.featuredArtist], to: original, change: .add) == [.songwriter, .producer, .featuredArtist])
        precondition(SiriRoleSet.applying([.producer], to: original, change: .remove) == [.songwriter])
        precondition(SiriRoleSet.applying([.mixingEngineer], to: original, change: .replace) == [.mixingEngineer])

        precondition(SiriWorkflowTests.isValidSplit(0))
        precondition(SiriWorkflowTests.isValidSplit(100))
        precondition(!SiriWorkflowTests.isValidSplit(.infinity))
        precondition(!SiriWorkflowTests.isValidSplit(-1))
        precondition(!SiriWorkflowTests.isValidSplit(101))

        let allocationConfirmation = SiriAttachAllocationConfirmationFormatter.format(
            collaboratorName: "Sugar",
            songTitle: "Walk It Like I Talk It",
            roleText: "Featured Artist",
            preview: SiriSplitPreview(
                collaboratorMaster: 20,
                collaboratorPublishing: 0,
                primaryMaster: 80,
                primaryPublishing: 100
            )
        )
        precondition(allocationConfirmation.contains("20 percent master"))
        precondition(allocationConfirmation.contains("80 percent master and 100 percent publishing"))
        precondition(
            SiriRoleChangeConfirmationFormatter.format(
                change: .replace,
                collaboratorName: "Sugar",
                roleName: "Featured Artist",
                songTitle: "Walk It Like I Talk It"
            ).contains("Replace Sugar's roles")
        )

        let collaborator = Collaborator(artistName: "Sugar", songwriterName: "James Taylor", preferredPRO: .ascap, defaultContributions: [.featuredArtist])
        let song = Song(
            title: "Walk It Like I Talk It",
            phase: .recording,
            primaryArtist: "Primary Artist",
            primarySongwriter: "Primary Writer",
            collaborators: [collaborator],
            distributor: Distributor(preset: .distrokid, customName: nil),
            primarySplits: SplitAllocation(master: 80, publishing: 100),
            collaboratorSplits: [collaborator.id: SplitAllocation(master: 20, publishing: 0)]
        )
        precondition(SiriSongSplitValidator.isValid(song))
        precondition(SiriSongSummaryFormatter.format(song).contains("1 collaborator"))
        precondition(SiriReadinessFormatter.format(song).contains("registration items"))
        precondition(
            SiriAttentionFormatter.format(
                songs: [song],
                filter: .incompleteRegistration,
                phase: nil
            ).contains("Walk It Like I Talk It")
        )
        print("Siri workflow role, split, and report checks passed.")
    }

    private static func isValidSplit(_ value: Double) -> Bool {
        value.isFinite && (0 ... 100).contains(value)
    }
}
