import Foundation
import SwiftUI

/// Palet warna kartu lirik untuk dibagikan ke Instagram Story
public struct SharePalette: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let topColorHex: String
    public let bottomColorHex: String
    public let primaryTextColor: Color
    public let secondaryTextColor: Color

    public var topColor: Color {
        Color(hex: topColorHex)
    }

    public var bottomColor: Color {
        Color(hex: bottomColorHex)
    }

    public var gradient: LinearGradient {
        LinearGradient(
            colors: [topColor, bottomColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static let palettes: [SharePalette] = [
        SharePalette(
            id: "olive",
            name: "Olive",
            topColorHex: "#3F4F38",
            bottomColorHex: "#1E271B",
            primaryTextColor: .white,
            secondaryTextColor: Color.white.opacity(0.7)
        ),
        SharePalette(
            id: "spotify-blue",
            name: "Spotify Blue",
            topColorHex: "#1E3264",
            bottomColorHex: "#0D172E",
            primaryTextColor: .white,
            secondaryTextColor: Color.white.opacity(0.7)
        ),
        SharePalette(
            id: "emerald",
            name: "Emerald",
            topColorHex: "#1DB954",
            bottomColorHex: "#0C4A21",
            primaryTextColor: .black,
            secondaryTextColor: Color.black.opacity(0.7)
        ),
        SharePalette(
            id: "purple",
            name: "Purple",
            topColorHex: "#6B2D5C",
            bottomColorHex: "#2E0F26",
            primaryTextColor: .white,
            secondaryTextColor: Color.white.opacity(0.7)
        ),
        SharePalette(
            id: "sunset",
            name: "Sunset",
            topColorHex: "#E65C40",
            bottomColorHex: "#5E180A",
            primaryTextColor: .white,
            secondaryTextColor: Color.white.opacity(0.7)
        ),
        SharePalette(
            id: "midnight",
            name: "Midnight",
            topColorHex: "#1A1D24",
            bottomColorHex: "#0A0B0E",
            primaryTextColor: .white,
            secondaryTextColor: Color.white.opacity(0.7)
        )
    ]
}

// MARK: - Color Hex Extension
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
