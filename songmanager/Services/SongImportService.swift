import Foundation
import CoreData

struct SongImportResult {
    let importedCount: Int
    let skippedExistingTitles: [String]
    let limitedByCap: Bool
}

struct SongImportPayload {
    let title: String
    let artist: String?
    let album: String?
    let composer: String?
    let persistentID: UInt64?
}

enum SongImportService {
    static let importLimit = 100

    static func normalizePayloads(_ payloads: [SongImportPayload]) -> [SongImportPayload] {
        var seen = Set<String>()
        var ordered: [SongImportPayload] = []
        for payload in payloads {
            let trimmedTitle = payload.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedTitle.isEmpty == false else { continue }
            let key = trimmedTitle.lowercased()
            if seen.contains(key) == false {
                seen.insert(key)
                ordered.append(SongImportPayload(
                    title: trimmedTitle,
                    artist: payload.artist,
                    album: payload.album,
                    composer: payload.composer,
                    persistentID: payload.persistentID
                ))
            }
        }
        return ordered
    }

    static func importSongs(_ payloads: [SongImportPayload], context: NSManagedObjectContext, profile: UserProfile) -> SongImportResult {
        let normalized = normalizePayloads(payloads)
        let limited = Array(normalized.prefix(importLimit))
        let limitedByCap = normalized.count > importLimit

        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        let existingTitles: Set<String>
        if let fetched = try? context.fetch(request) {
            let lowercased = fetched.compactMap { $0.title?.lowercased() }
            existingTitles = Set(lowercased)
        } else {
            existingTitles = []
        }

        var skipped: [String] = []
        var inserted = 0
        for payload in limited {
            if existingTitles.contains(payload.title.lowercased()) {
                skipped.append(payload.title)
                continue
            }

            let song = SongEntity(context: context)
            song.id = UUID()
            song.title = payload.title
            song.createdAt = Date()
            song.phase = SongPhase.pending.rawValue
            song.primaryArtist = profile.artistName
            song.primarySongwriter = profile.songwriterName
            song.distributorPreset = profile.distributor.preset.rawValue
            song.distributorCustomName = profile.distributor.customName
            if let persistentID = payload.persistentID {
                song.mediaLibraryPersistentID = Int64(persistentID)
            }
            song.primarySplitsMaster = 100
            song.primarySplitsPublishing = 100
            song.primaryContributionsRaw = AppStateViewModel.encodeContributions(profile.defaultContributions)
            song.checklistPro = false
            song.checklistMlc = false
            song.checklistHfa = false
            song.checklistSoundExchange = false
            song.checklistMusicReports = false
            song.checklistDistributorSubmitted = false
            song.notes = buildNote(from: payload)
            inserted += 1
        }

        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Failed to save imported songs: \(error)")
        }

        return SongImportResult(importedCount: inserted, skippedExistingTitles: skipped, limitedByCap: limitedByCap)
    }

    static func buildNote(from payload: SongImportPayload) -> String {
        var lines: [String] = ["Imported from Apple Music Library"]
        if let artist = payload.artist, artist.isEmpty == false {
            lines.append("Artist: \(artist)")
        }
        if let album = payload.album, album.isEmpty == false {
            lines.append("Album: \(album)")
        }
        if let composer = payload.composer, composer.isEmpty == false {
            lines.append("Composer: \(composer)")
        }
        return lines.joined(separator: "\n")
    }
}
