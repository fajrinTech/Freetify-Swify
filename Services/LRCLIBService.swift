import Foundation

/// Service untuk mengambil lirik tersinkronisasi dari LRCLIB API secara live dan akurat
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
    public func fetchLyrics(title: String, artist: String, duration: TimeInterval = 0) async -> String? {
        // Bersihkan judul dari embel-embel seperti "(feat. ...)", "[Official HD Video]", dll.
        let cleanTitle = cleanTrackTitle(title)
        let cleanArtist = cleanArtistName(artist)

        // 1. Coba endpoint spesifik /api/get
        if let exactLyrics = await fetchExact(trackName: cleanTitle, artistName: cleanArtist, duration: duration) {
            return exactLyrics
        }

        // 2. Coba endpoint pencarian /api/search
        if let searchLyrics = await searchLyrics(query: "\(cleanTitle) \(cleanArtist)") {
            return searchLyrics
        }

        // 3. Fallback pencarian dengan judul asli
        if cleanTitle != title {
            return await searchLyrics(query: title)
        }

        return nil
    }

    private func fetchExact(trackName: String, artistName: String, duration: TimeInterval) async -> String? {
        var components = URLComponents(string: "https://lrclib.net/api/get")
        var queryItems = [
            URLQueryItem(name: "track_name", value: trackName),
            URLQueryItem(name: "artist_name", value: artistName)
        ]
        if duration > 0 {
            queryItems.append(URLQueryItem(name: "duration", value: String(Int(duration))))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Freetify-iOS/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 8.0

        guard let (data, response) = try? await session.data(for: request),
              let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
              let record = try? JSONDecoder().decode(LRCLIBRecord.self, from: data) else {
            return nil
        }

        if let synced = record.syncedLyrics, !synced.isEmpty {
            return synced
        }
        return record.plainLyrics
    }

    private func searchLyrics(query: String) async -> String? {
        var components = URLComponents(string: "https://lrclib.net/api/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]

        guard let url = components?.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Freetify-iOS/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 8.0

        guard let (data, response) = try? await session.data(for: request),
              let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
              let records = try? JSONDecoder().decode([LRCLIBRecord].self, from: data) else {
            return nil
        }

        // Prioritaskan hasil pertama yang memiliki syncedLyrics
        if let syncedRecord = records.first(where: { $0.syncedLyrics != nil && !($0.syncedLyrics?.isEmpty ?? true) }) {
            return syncedRecord.syncedLyrics
        }

        // Fallback ke plainLyrics jika tidak ada syncedLyrics
        if let plainRecord = records.first(where: { $0.plainLyrics != nil && !($0.plainLyrics?.isEmpty ?? true) }),
           let plain = plainRecord.plainLyrics {
            return plain.components(separatedBy: .newlines)
                .enumerated()
                .map { index, line in "[00:\(String(format: "%02d", index * 4)).00] \(line)" }
                .joined(separator: "\n")
        }

        return nil
    }

    private func cleanTrackTitle(_ title: String) -> String {
        var cleaned = title
        // Hapus (feat. ...) atau (ft. ...)
        if let regex = try? NSRegularExpression(pattern: "\\s*\\((?:feat|ft|with|official)[^\\)]*\\)", options: [.caseInsensitive]) {
            let range = NSRange(cleaned.startIndex..<cleaned.endIndex, in: cleaned)
            cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: range, withTemplate: "")
        }
        // Hapus [Official ...] atau [HD]
        if let regex = try? NSRegularExpression(pattern: "\\s*\\[[^\\]]*\\]", options: [.caseInsensitive]) {
            let range = NSRange(cleaned.startIndex..<cleaned.endIndex, in: cleaned)
            cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: range, withTemplate: "")
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func cleanArtistName(_ artist: String) -> String {
        // Ambil artis utama sebelum koma atau feat
        let separators = [",", "&", "feat.", "ft.", "with"]
        var cleaned = artist
        for sep in separators {
            if let range = cleaned.range(of: sep, options: .caseInsensitive) {
                cleaned = String(cleaned[..<range.lowerBound])
            }
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
