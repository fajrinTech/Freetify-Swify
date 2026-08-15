import Foundation
import UIKit
import SwiftUI

/// Layanan berbagi kartu lirik ke Instagram Stories via UIPasteboard dan URL Scheme Meta
@MainActor
public final class InstagramShareService {
    public static let shared = InstagramShareService()

    private init() {}

    /// Mengecek apakah aplikasi Instagram terpasang di perangkat
    public var isInstagramInstalled: Bool {
        guard let instagramURL = URL(string: "instagram-stories://share") else { return false }
        return UIApplication.shared.canOpenURL(instagramURL)
    }

    /// Membagikan gambar stiker lirik yang di-render ke Instagram Stories
    public func shareLyricsToInstagramStories(
        stickerImage: UIImage,
        palette: SharePalette,
        track: Track
    ) {
        guard let stickerData = stickerImage.pngData() else {
            print("[InstagramShareService] Gagal mengonversi stickerImage ke PNG data.")
            return
        }

        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.stickerImage": stickerData,
            "com.instagram.sharedSticker.backgroundTopColor": palette.topColorHex,
            "com.instagram.sharedSticker.backgroundBottomColor": palette.bottomColorHex,
            "com.instagram.sharedSticker.contentURL": track.audioURL.absoluteString
        ]

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(300) // Kadaluarsa dalam 5 menit
        ]

        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)

        guard let url = URL(string: "instagram-stories://share") else { return }
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                print("[InstagramShareService] Gagal membuka Instagram Stories URL Scheme.")
            }
        }
    }
}
