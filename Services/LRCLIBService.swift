import Foundation

/// Service untuk mengambil lirik tersinkronisasi dari LRCLIB API secara live
public final class LRCLIBService: Sendable {
    public static let shared = LRCLIBService()

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct LRCLIBRecord: Codable {
        let id: Int?
        let trackName: String?
        let artistName: String?
        let albumName: String?
        let duration: Double?
        let plainLyrics: String?
        let syncedLyrics: String?
    }

    /// Mengambil string LRC dari LRCLIB berdasarkan judul dan nama artis
    public func fetchLyrics(title: String, artist: String) async -> String? {
        var components = URLComponents(string: "https://lrclib.net/api/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: "\(title) \(artist)")
        ]
        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Freetify-iOS/1.0 (https://github.com/fajrin/Freetify)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10.0

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return nil
            }

            let records = try JSONDecoder().decode([LRCLIBRecord].self, from: data)

            // Prioritaskan hasil yang memiliki syncedLyrics
            if let syncedRecord = records.first(where: { $0.syncedLyrics != nil && !($0.syncedLyrics?.isEmpty ?? true) }) {
                return syncedRecord.syncedLyrics
            }

            // Fallback ke plainLyrics jika tidak ada syncedLyrics
            if let plainRecord = records.first(where: { $0.plainLyrics != nil && !($0.plainLyrics?.isEmpty ?? true) }),
               let plain = plainRecord.plainLyrics {
                // Buat pseudo-LRC jika hanya plain text
                return plain.components(separatedBy: .newlines)
                    .enumerated()
                    .map { index, line in "[00:\(String(format: "%02d", index * 4)).00] \(line)" }
                    .joined(separator: "\n")
            }

            return nil
        } catch {
            print("[LRCLIBService] Error fetching lyrics: \(error.localizedDescription)")
            return nil
        }
    }
}
