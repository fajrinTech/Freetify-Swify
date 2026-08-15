import SwiftUI

/// Kartu profil 'Tentang Artis' yang tampil di bagian bawah layar Now Playing
public struct ArtistCardView: View {
    public let track: Track

    public init(track: Track) {
        self.track = track
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Image Artis dengan Overlay Gradasi
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: track.artistHeroURL ?? track.artworkURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        LinearGradient(
                            colors: [Color(hex: "2A323D"), Color(hex: "15191E")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .frame(height: 220)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.85)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                }

                // Info Artis di Atas Gambar
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tentang artis")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .textCase(.uppercase)

                    HStack(spacing: 6) {
                        Text(track.artist)
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.white)

                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: "1DB954"))
                            .font(.system(size: 16))
                    }
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            // Deskripsi Biografi Artis
            if let bio = track.artistBio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(4)
                    .lineSpacing(4)
                    .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .liquidGlassCard(cornerRadius: 24, tint: Color.white.opacity(0.06))
    }
}
