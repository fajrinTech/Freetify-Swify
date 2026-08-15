import Foundation

/// Parser untuk format lirik tersinkronisasi .LRC
public enum LRCParser {
    /// Parsing teks berformat LRC menjadi array LyricLine terurut berdasarkan waktu (detik)
    public static func parse(_ lrcContent: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        let rawLines = lrcContent.components(separatedBy: .newlines)

        // Pattern regex mencocokkan [mm:ss.xx] atau [mm:ss.xxx]
        let pattern = "\\[(\\d{2}):(\\d{2})(?:\\.(\\d{2,3}))?\\](.*)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        for rawLine in rawLines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
            let matches = regex.matches(in: trimmed, options: [], range: range)

            for match in matches {
                guard match.numberOfRanges >= 3,
                      let minRange = Range(match.range(at: 1), in: trimmed),
                      let secRange = Range(match.range(at: 2), in: trimmed) else {
                    continue
                }

                let minutes = Double(trimmed[minRange]) ?? 0
                let seconds = Double(trimmed[secRange]) ?? 0
                var fraction: Double = 0

                if match.numberOfRanges >= 4,
                   let fracRange = Range(match.range(at: 3), in: trimmed),
                   !trimmed[fracRange].isEmpty {
                    let fracStr = String(trimmed[fracRange])
                    let divisor = pow(10.0, Double(fracStr.count))
                    fraction = (Double(fracStr) ?? 0) / divisor
                }

                var text = ""
                if match.numberOfRanges >= 5,
                   let textRange = Range(match.range(at: 4), in: trimmed) {
                    text = String(trimmed[textRange]).trimmingCharacters(in: .whitespaces)
                }

                // Abaikan jika baris kosong / hanya tag metadata seperti [ar:], [ti:]
                guard !text.isEmpty else { continue }

                let totalTime = (minutes * 60.0) + seconds + fraction
                lines.append(LyricLine(time: totalTime, text: text))
            }
        }

        return lines.sorted { $0.time < $1.time }
    }
}
