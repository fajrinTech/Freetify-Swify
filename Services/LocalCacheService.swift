import Foundation

/// Layanan penyimpanan cache offline untuk lirik dan preferensi lagu favorit
public final class LocalCacheService: @unchecked Sendable {
    public static let shared = LocalCacheService()

    private let userDefaults: UserDefaults
    private let favoritesKey = "freetify_favorite_track_ids"
    private let lyricsCachePrefix = "freetify_lrc_cache_"

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

    // MARK: - Lyrics Caching
    public func cacheLyrics(trackID: String, lrcText: String) {
        let key = lyricsCachePrefix + trackID
        userDefaults.set(lrcText, forKey: key)
    }

    public func getCachedLyrics(trackID: String) -> String? {
        let key = lyricsCachePrefix + trackID
        return userDefaults.string(forKey: key)
    }
}
