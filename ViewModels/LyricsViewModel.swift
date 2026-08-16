import Foundation
import SwiftUI
import Observation

/// ViewModel pengatur sinkronisasi lirik karaoke, pencarian lirik live LRCLIB, dan seleksi Instagram Story
@Observable
@MainActor
public final class LyricsViewModel {
    public var lines: [LyricLine] = []
    public var activeLineIndex: Int = 0
    public var isLoading: Bool = false
    public var selectedLines: [LyricLine] = []
    public var selectedPalette: SharePalette = SharePalette.palettes[0]
    public var isShareModalPresented: Bool = false

    private let lrclibService = LRCLIBService.shared
    private let cacheService = LocalCacheService.shared
    private var currentLoadedTrackID: String?

    public init() {}

    /// Memuat dan sinkronisasi lirik untuk lagu tertentu
    public func loadLyrics(for track: Track) async {
        if currentLoadedTrackID == track.id && !lines.isEmpty {
            return
        }

        currentLoadedTrackID = track.id
        self.lines = [] // Reset lirik seketika agar tidak tercampur
        self.selectedLines = []
        self.activeLineIndex = 0

        // 1. Cek lirik yang sudah tersemat langsung di model Track (hanya jika format LRC valid)
        if let lrc = track.lyricsLRC, !lrc.isEmpty, isFormatValidLRC(lrc) {
            let parsed = LRCParser.parse(lrc)
            if !parsed.isEmpty {
                self.lines = parsed
                return
            }
        }

        // 2. Cek cache lokal v3
        if let cachedLrc = cacheService.getCachedLyrics(trackID: track.id), isFormatValidLRC(cachedLrc) {
            let parsed = LRCParser.parse(cachedLrc)
            if !parsed.isEmpty {
                self.lines = parsed
                return
            }
        }

        // 3. Fallback: Ambil secara live dari LRCLIB API
        isLoading = true
        if let fetchedLrc = await lrclibService.fetchLyrics(title: track.title, artist: track.artist, duration: track.duration) {
            if currentLoadedTrackID == track.id {
                let parsed = LRCParser.parse(fetchedLrc)
                if !parsed.isEmpty {
                    self.lines = parsed
                    cacheService.cacheLyrics(trackID: track.id, lrcText: fetchedLrc)
                } else {
                    self.lines = []
                }
            }
        } else {
            if currentLoadedTrackID == track.id {
                self.lines = []
            }
        }
        isLoading = false
    }

    /// Validasi apakah teks mengandung timestamp standar LRC [mm:ss]
    private func isFormatValidLRC(_ text: String) -> Bool {
        return text.contains("[00:") || text.contains("[01:") || text.contains("[02:") || text.contains("[03:") || text.contains("[04:")
    }

    /// Memperbarui indeks baris lirik yang sedang aktif sesuai detik lagu yang dimainkan
    public func updateActiveLine(currentTime: TimeInterval) {
        guard !lines.isEmpty else {
            activeLineIndex = 0
            return
        }

        // Cari baris terakhir yang waktunya <= currentTime
        var foundIndex = 0
        for (index, line) in lines.enumerated() {
            if currentTime >= line.time {
                foundIndex = index
            } else {
                break
            }
        }

        if activeLineIndex != foundIndex {
            activeLineIndex = foundIndex
        }
    }

    /// Menambah atau menghapus baris dari seleksi kartu Instagram Story (Maksimal 5 baris)
    public func toggleLineSelection(_ line: LyricLine) {
        if let index = selectedLines.firstIndex(where: { $0.id == line.id }) {
            selectedLines.remove(at: index)
        } else {
            if selectedLines.count < 5 {
                selectedLines.append(line)
                selectedLines.sort { $0.time < $1.time }
            }
        }
    }

    public func isLineSelected(_ line: LyricLine) -> Bool {
        selectedLines.contains(where: { $0.id == line.id })
    }
}
