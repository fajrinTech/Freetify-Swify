import Foundation

/// Layanan integrasi backend Supabase (PostgreSQL & Storage) untuk katalog musik Freetify
public final class SupabaseService: Sendable {
    public static let shared = SupabaseService()

    public struct SupabaseConfig: Sendable {
        public let url: String
        public let anonKey: String

        public init(
            url: String? = nil,
            anonKey: String? = nil
        ) {
            let plistURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
            let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"]
            let resolvedURL = url ?? plistURL ?? envURL ?? "https://uzxilupjdtenbuzlmzui.supabase.co"
            self.url = (resolvedURL.isEmpty || resolvedURL.hasPrefix("$(")) ? "https://uzxilupjdtenbuzlmzui.supabase.co" : resolvedURL

            let plistKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
            let envKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
            let resolvedKey = anonKey ?? plistKey ?? envKey ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6eGlsdXBqZHRlbmJ1emxtenVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5MTI4ODAsImV4cCI6MjEwMTQ4ODg4MH0.SeCoVstbx0NolCljrwux61JUb6JsqqeMuB9dC82aQh8"
            self.anonKey = (resolvedKey.isEmpty || resolvedKey.hasPrefix("$(")) ? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6eGlsdXBqZHRlbmJ1emxtenVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5MTI4ODAsImV4cCI6MjEwMTQ4ODg4MH0.SeCoVstbx0NolCljrwux61JUb6JsqqeMuB9dC82aQh8" : resolvedKey
        }
    }

    private let config: SupabaseConfig
    private let session: URLSession

    public init(config: SupabaseConfig = SupabaseConfig(), session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    /// Struktur DTO respons tabel `songs` di Supabase
    private struct SupabaseSongDTO: Codable {
        let id: String
        let title: String?
        let artist: String?
        let album: String?
        let duration: Double?
        let filePath: String?
        let coverPath: String?
        let lyrics: String?
    }

    /// Mengambil daftar lagu nyata dari tabel `songs` di Supabase Database
    public func fetchSongs() async throws -> [Track] {
        guard let endpoint = URL(string: "\(config.url)/rest/v1/songs?select=*") else {
            return Track.samples
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 12.0

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return Track.samples
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let dtos = try decoder.decode([SupabaseSongDTO].self, from: data)

            let favoriteIDs = await MainActor.run {
                LocalCacheService.shared.getFavoriteIDs()
            }

            let cloudTracks: [Track] = dtos.compactMap { row in
                guard let audioUrlString = row.filePath, let audioURL = URL(string: audioUrlString) else {
                    return nil
                }

                let artworkURL = row.coverPath.flatMap { URL(string: $0) }

                return Track(
                    id: row.id,
                    title: row.title ?? "Lagu Tanpa Judul",
                    artist: row.artist ?? "Artis Freetify",
                    album: row.album ?? "Single",
                    artworkURL: artworkURL,
                    audioURL: audioURL,
                    duration: row.duration ?? 180.0,
                    lyricsLRC: row.lyrics,
                    isFavorite: favoriteIDs.contains(row.id),
                    artistHeroURL: artworkURL,
                    artistBio: "Artis di platform musik Freetify.",
                    supabaseId: row.id
                )
            }

            return cloudTracks.isEmpty ? Track.samples : cloudTracks
        } catch {
            print("[SupabaseService] Error fetch Supabase songs: \(error.localizedDescription)")
            return Track.samples
        }
    }
}
