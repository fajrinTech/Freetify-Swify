import Foundation

/// Model baris lirik tersinkronisasi
public struct LyricLine: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let time: TimeInterval
    public let text: String

    public init(id: UUID = UUID(), time: TimeInterval, text: String) {
        self.id = id
        self.time = time
        self.text = text
    }

    /// Format waktu menit:detik untuk display
    public var formattedTime: String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
