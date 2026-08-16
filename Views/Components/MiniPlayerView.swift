import SwiftUI
import Observation

/// Floating Mini Player yang melayang tepat di atas TabBar dengan gesture tap untuk membuka layar penuh
public struct MiniPlayerView: View {
    @Environment(PlayerViewModel.self) private var playerVM

    public init() {}

    public var body: some View {
        if let track = playerVM.currentTrack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Artwork Gambar & Info Lagu (Ketuk untuk Buka Layar Penuh)
                    HStack(spacing: 12) {
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
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        playerVM.isNowPlayingPresented = true
                    }

                    Spacer(minLength: 8)

                    // Tombol Favorit Independen
                    Button {
                        playerVM.toggleFavorite(for: track)
                    } label: {
                        Image(systemName: track.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(track.isFavorite ? Color(hex: "00F2FE") : .white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    // Tombol Play / Pause Independen
                    Button {
                        playerVM.togglePlayPause()
                    } label: {
                        Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)

                // Garis Progres Pemutaran Tipis di Bawah (Aman dari NaN / Bounds Clamp)
                GeometryReader { geo in
                    let validProgress = max(0.0, min(playerVM.progress, 1.0))
                    let barWidth = max(0.0, min(geo.size.width * CGFloat(validProgress), geo.size.width))

                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 2)

                        Rectangle()
                            .fill(Color(hex: "00F2FE"))
                            .frame(width: barWidth, height: 2)
                    }
                }
                .frame(height: 2)
            }
            .liquidGlassCard(cornerRadius: 16, tint: Color(hex: "12161E").opacity(0.92))
            .padding(.horizontal, 16)
            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
