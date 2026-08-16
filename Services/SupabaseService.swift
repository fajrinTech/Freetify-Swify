import Foundation

/// Layanan integrasi backend Supabase (PostgreSQL & Storage) untuk katalog musik Freetify
public final class SupabaseService: Sendable {
    public static let shared = SupabaseService()

    public struct SupabaseConfig: Sendable {
        public static let defaultURL = "https://uzxilupjdtenbuzlmzui.supabase.co"
        public static let defaultAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6eGlsdXBqZHRlbmJ1emxtenVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5MTI4ODAsImV4cCI6MjEwMTQ4ODg4MH0.SeCoVstbx0NolCljrwux61JUb6JsqqeMuB9dC82aQh8"

        public let url: String
        public let anonKey: String

        public init(
            url: String? = nil,
            anonKey: String? = nil
        ) {
            let plistURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
            let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"]
            let candidateURL = [url, plistURL, envURL].compactMap { $0 }.first(where: {
                let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmed.isEmpty && !trimmed.contains("$")
            })
            self.url = candidateURL ?? Self.defaultURL

            let plistKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
            let envKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
            let candidateKey = [anonKey, plistKey, envKey].compactMap { $0 }.first(where: {
                let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmed.isEmpty && !trimmed.contains("$")
            })
            self.anonKey = candidateKey ?? Self.defaultAnonKey
        }
    }

    private let config: SupabaseConfig
    private let session: URLSession

    public init(config: SupabaseConfig = SupabaseConfig(), session: URLSession = .shared) {
        self.config = config
        self.session = session
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
        request.timeoutInterval = 15.0

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return Track.samples
            }

            let favoriteIDs = await MainActor.run {
                LocalCacheService.shared.getFavoriteIDs()
            }

            // Parsing robust via JSONSerialization agar kebal terhadap variasi tipe data
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                return Track.samples
            }

            let cloudTracks: [Track] = jsonArray.compactMap { dict in
                guard let id = dict["id"] as? String ?? (dict["id"] as? CustomStringConvertible)?.description,
                      let filePath = dict["file_path"] as? String,
                      let audioURL = URL(string: filePath) else {
                    return nil
                }

                let title = dict["title"] as? String ?? "Lagu Tanpa Judul"
                let artist = dict["artist"] as? String ?? "Artis Freetify"
                let album = dict["album"] as? String ?? "Single"
                let coverPath = dict["cover_path"] as? String
                let artworkURL = coverPath.flatMap { URL(string: $0) }

                let rawDur = dict["duration"]
                let duration: Double
                if let d = rawDur as? Double {
                    duration = d
                } else if let i = rawDur as? Int {
                    duration = Double(i)
                } else if let s = rawDur as? String, let parsed = Double(s) {
                    duration = parsed
                } else {
                    duration = 180.0
                }

                let lyrics = dict["lyrics"] as? String

                return Track(
                    id: id,
                    title: title,
                    artist: artist,
                    album: album,
                    artworkURL: artworkURL,
                    audioURL: audioURL,
                    duration: (duration > 0 && !duration.isNaN) ? duration : 180.0,
                    lyricsLRC: lyrics,
                    isFavorite: favoriteIDs.contains(id),
                    artistHeroURL: artworkURL,
                    artistBio: "Artis di platform musik Freetify.",
                    supabaseId: id
                )
            }

            return cloudTracks.isEmpty ? Track.samples : cloudTracks
        } catch {
            print("[SupabaseService] Error fetch Supabase songs: \(error.localizedDescription)")
            return Track.samples
        }
    }
}
