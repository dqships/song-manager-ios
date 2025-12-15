import SwiftUI
import MediaPlayer

struct MusicImportPicker: UIViewControllerRepresentable {
    var onPick: ([SongImportPayload]) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.allowsPickingMultipleItems = true
        picker.showsCloudItems = true
        picker.prompt = "Select songs to import"
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, MPMediaPickerControllerDelegate {
        let parent: MusicImportPicker

        init(parent: MusicImportPicker) {
            self.parent = parent
        }

        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            let payloads = mediaItemCollection.items.compactMap { item -> SongImportPayload? in
                guard let title = item.title else { return nil }
                return SongImportPayload(
                    title: title,
                    artist: item.artist,
                    album: item.albumTitle,
                    composer: item.composer,
                    persistentID: item.persistentID
                )
            }
            parent.onPick(payloads)
            mediaPicker.dismiss(animated: true)
        }

        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            parent.onCancel()
            mediaPicker.dismiss(animated: true)
        }
    }
}
