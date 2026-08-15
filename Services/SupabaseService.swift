import Foundation

/// Layanan integrasi backend Supabase (PostgreSQL & Storage) untuk katalog lagu Freetify
public final class SupabaseService: Sendable {
    public static let shared = SupabaseService()

    public struct SupabaseConfig: Sendable {
        public let url: String
        public let anonKey: String

        public init(
            url: String = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://xyzcompany.supabase.co",
            anonKey: String = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "public-anon-key"
        ) {
            self.url = url
            self.anonKey = anonKey
        }
    }

    private let config: SupabaseConfig
    private let session: URLSession

    public init(config: SupabaseConfig = SupabaseConfig(), session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    /// Mengambil daftar lagu dari tabel `songs` di Supabase
    public func fetchSongs() async throws -> [Track] {
        guard let endpoint = URL(string: "\(config.url)/rest/v1/songs?select=*") else {
            return Track.samples
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10.0

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                // Fallback ke sampel track jika remote belum terhubung / offline
                return Track.samples
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let tracks = try decoder.decode([Track].self, from: data)
            return tracks.isEmpty ? Track.samples : tracks
        } catch {
            print("[SupabaseService] Menggunakan sample tracks offline: \(error.localizedDescription)")
            return Track.samples
        }
    }
}
