import Foundation

/// Layanan penyimpanan cache offline untuk audio, lirik, dan preferensi lagu favorit
public final class LocalCacheService: @unchecked Sendable {
    public static let shared = LocalCacheService()

    private let userDefaults: UserDefaults
    private let fileManager = FileManager.default
    private let favoritesKey = "freetify_favorite_track_ids"
    private let lyricsCachePrefix = "freetify_lrc_cache_v3_"

    private var audioCacheDir: URL {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = caches.appendingPathComponent("FreetifyAudio", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Favorites Management
    public func getFavoriteIDs() -> Set<String> {
        let array = userDefaults.stringArray(forKey: favoritesKey) ?? []
        return Set(array)
    }

    public func toggleFavorite(trackID: String) -> Bool {
        var favorites = getFavoriteIDs()
        let isNowFavorite: Bool
        if favorites.contains(trackID) {
            favorites.remove(trackID)
            isNowFavorite = false
        } else {
            favorites.insert(trackID)
            isNowFavorite = true
        }
        userDefaults.set(Array(favorites), forKey: favoritesKey)
        return isNowFavorite
    }

    // MARK: - Smart Audio Disk Cache (Offline Playback)
    public func getLocalAudioURL(trackID: String) -> URL? {
        let fileURL = audioCacheDir.appendingPathComponent("\(trackID).mp3")
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        return nil
    }

    public func cacheAudioFile(trackID: String, from remoteURL: URL) async {
        let destinationURL = audioCacheDir.appendingPathComponent("\(trackID).mp3")
        guard !fileManager.fileExists(atPath: destinationURL.path) else { return }

        do {
            let (tempURL, _) = try await URLSession.shared.download(from: remoteURL)
            if fileManager.fileExists(atPath: destinationURL.path) {
                try? fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: tempURL, to: destinationURL)
        } catch {
            print("[LocalCacheService] Gagal download cache audio: \(error.localizedDescription)")
        }
    }

    // MARK: - Lyrics Caching (v3 Versioned Cache)
    public func cacheLyrics(trackID: String, lrcText: String) {
        let key = lyricsCachePrefix + trackID
        userDefaults.set(lrcText, forKey: key)
    }

    public func getCachedLyrics(trackID: String) -> String? {
        let key = lyricsCachePrefix + trackID
        return userDefaults.string(forKey: key)
    }

    public func clearAllLyricsCache() {
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys where key.hasPrefix("freetify_lrc_cache_") {
            userDefaults.removeObject(forKey: key)
        }
    }
}
