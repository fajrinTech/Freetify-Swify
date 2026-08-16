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
        self.lines = [] // Reset lirik lagu sebelumnya seketika agar tidak tercampur
        self.selectedLines = []
        self.activeLineIndex = 0

        // 1. Cek lirik yang sudah tersemat langsung di model Track
        if let lrc = track.lyricsLRC, !lrc.isEmpty {
            self.lines = LRCParser.parse(lrc)
            return
        }

        // 2. Cek cache lokal
        if let cachedLrc = cacheService.getCachedLyrics(trackID: track.id) {
            self.lines = LRCParser.parse(cachedLrc)
            return
        }

        // 3. Fallback: Ambil secara live dari LRCLIB API
        isLoading = true
        if let fetchedLrc = await lrclibService.fetchLyrics(title: track.title, artist: track.artist, duration: track.duration) {
            // Pastikan track yang sedang dimuat masih sama saat respons tiba
            if currentLoadedTrackID == track.id {
                self.lines = LRCParser.parse(fetchedLrc)
                cacheService.cacheLyrics(trackID: track.id, lrcText: fetchedLrc)
            }
        } else {
            if currentLoadedTrackID == track.id {
                self.lines = []
            }
        }
        isLoading = false
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
                // Urutkan kembali sesuai timestamp aslinya
                selectedLines.sort { $0.time < $1.time }
            }
        }
    }

    public func isLineSelected(_ line: LyricLine) -> Bool {
        selectedLines.contains(where: { $0.id == line.id })
    }
}
