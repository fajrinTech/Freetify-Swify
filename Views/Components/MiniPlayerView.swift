import SwiftUI
import Observation

/// Floating Mini Player yang melayang tepat di atas TabBar dengan gesture tap untuk membuka layar penuh
public struct MiniPlayerView: View {
    @Environment(PlayerViewModel.self) private var playerVM

    public init() {}

    public var body: some View {
        if let track = playerVM.currentTrack {
            Button {
                playerVM.isNowPlayingPresented = true
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        // Artwork Gambar
                        AsyncImage(url: track.artworkURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay {
                                        Image(systemName: "music.note")
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                            }
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                        // Judul Lagu & Artis
                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(track.artist)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }

                        Spacer(minLength: 8)

                        // Tombol Favorit
                        Button {
                            playerVM.toggleFavorite(for: track)
                        } label: {
                            Image(systemName: track.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(track.isFavorite ? Color(hex: "1DB954") : .white.opacity(0.7))
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)

                        // Tombol Play / Pause
                        Button {
                            playerVM.togglePlayPause()
                        } label: {
                            Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                    // Garis Progres Pemutaran Tipis di Bawah
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 2)

                            Rectangle()
                                .fill(Color.white)
                                .frame(width: geo.size.width * CGFloat(playerVM.progress), height: 2)
                        }
                    }
                    .frame(height: 2)
                }
                .liquidGlassCard(cornerRadius: 16, tint: Color(hex: "1E232B").opacity(0.92))
                .padding(.horizontal, 16)
                .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
