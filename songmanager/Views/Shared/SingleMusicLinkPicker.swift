import SwiftUI
import MediaPlayer

struct SingleMusicLinkPicker: UIViewControllerRepresentable {
    var onPick: (SongImportPayload?) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.allowsPickingMultipleItems = false
        picker.prompt = "Choose a song to link"
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, MPMediaPickerControllerDelegate {
        let parent: SingleMusicLinkPicker

        init(parent: SingleMusicLinkPicker) {
            self.parent = parent
        }

        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            let payload = mediaItemCollection.items.first.flatMap { item -> SongImportPayload? in
                guard let title = item.title else { return nil }
                return SongImportPayload(
                    title: title,
                    artist: item.artist,
                    album: item.albumTitle,
                    composer: item.composer,
                    persistentID: item.persistentID
                )
            }
            parent.onPick(payload)
            mediaPicker.dismiss(animated: true)
        }

        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            parent.onCancel()
            mediaPicker.dismiss(animated: true)
        }
    }
}
