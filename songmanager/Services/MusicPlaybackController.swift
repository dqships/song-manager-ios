import Foundation
import Combine
import MediaPlayer

@MainActor
final class MusicPlaybackController: ObservableObject {
    @Published private(set) var currentPersistentID: UInt64?
    @Published private(set) var isPlaying: Bool = false

    private let player = MPMusicPlayerController.applicationMusicPlayer
    private let service = MusicLibraryPlaybackService.shared
    private var observers: [NSObjectProtocol] = []

    init() {
        player.beginGeneratingPlaybackNotifications()
        observers.append(NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: player, queue: .main) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.syncState()
            }
        })
        observers.append(NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: .main) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.syncState()
            }
        })
        syncState()
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        player.endGeneratingPlaybackNotifications()
    }

    func toggle(for persistentID: UInt64, onFailure: (String) -> Void) {
        if let error = service.toggle(persistentID: persistentID) { onFailure(error); return }
        syncState()
    }

    func isPlaying(persistentID: UInt64) -> Bool {
        currentPersistentID == persistentID && isPlaying
    }

    private func syncState() {
        if let id = player.nowPlayingItem?.persistentID {
            currentPersistentID = UInt64(id)
        } else {
            currentPersistentID = nil
        }
        isPlaying = player.playbackState == .playing
    }
}
