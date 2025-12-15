import Foundation
import MediaPlayer

@MainActor
final class MusicLibraryPlaybackService {
    static let shared = MusicLibraryPlaybackService()

    private let player = MPMusicPlayerController.applicationMusicPlayer

    private init() {}

    func toggle(persistentID: UInt64) -> String? {
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            return "Allow Music access to play imported songs."
        }
        if player.nowPlayingItem?.persistentID == persistentID, player.playbackState == .playing {
            player.pause()
            return nil
        }
        return play(persistentID: persistentID)
    }

    func play(persistentID: UInt64) -> String? {
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            return "Allow Music access to play imported songs."
        }
        let predicate = MPMediaPropertyPredicate(value: persistentID, forProperty: MPMediaItemPropertyPersistentID)
        let query = MPMediaQuery.songs()
        query.addFilterPredicate(predicate)
        guard let item = query.items?.first else { return "Could not find this track in your library." }
        player.setQueue(with: MPMediaItemCollection(items: [item]))
        player.play()
        return nil
    }

    func pause() { player.pause() }

    func resume() { player.play() }

    var currentPersistentID: UInt64? { player.nowPlayingItem.map { UInt64($0.persistentID) } }

    var isPlaying: Bool { player.playbackState == .playing }
}
