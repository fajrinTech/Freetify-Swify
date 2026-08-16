import SwiftUI
import Observation

/// Layar Lirik Penuh (Karaoke Synced Lyrics View) dengan auto-scroll dan efek pencahayaan dinamis
public struct FullscreenLyricsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerViewModel.self) private var playerVM
    @Environment(LyricsViewModel.self) private var lyricsVM

    public init() {}

    public var body: some View {
        @Bindable var lyricsBinding = lyricsVM

        if let track = playerVM.currentTrack {
            ZStack {
                // Background Gelap dengan Ambient Artwork Tint
                ambientBackground(for: track)

                VStack(spacing: 0) {
                    // Header Atas
                    headerView(track: track)

                    // Daftar Lirik Karaoke Auto-Scrolling
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 26) {
                                ForEach(Array(lyricsVM.lines.enumerated()), id: \.element.id) { index, line in
                                    let isActive = (index == lyricsVM.activeLineIndex)

                                    Text(line.text)
                                        .font(.system(size: isActive ? 28 : 22, weight: isActive ? .heavy : .bold))
                                        .foregroundColor(isActive ? .white : .white.opacity(0.35))
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .shadow(color: isActive ? Color.white.opacity(0.5) : .clear, radius: 14, x: 0, y: 0)
                                        .scaleEffect(isActive ? 1.02 : 1.0, anchor: .leading)
                                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isActive)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                playerVM.seek(toSeconds: line.time)
                                            }
                                        }
                                        .id(index)
                                }

                                Spacer(minLength: 160)
                            }
                            .padding(.horizontal, 28)
                            .padding(.top, 24)
                        }
                        .onChange(of: lyricsVM.activeLineIndex) { _, newIndex in
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }

                    // Floating Bottom Toolbar: Tombol Bagikan Lirik
                    bottomToolbar()
                }
            }
            .task(id: track.id) {
                await lyricsVM.loadLyrics(for: track)
                lyricsVM.updateActiveLine(currentTime: playerVM.currentTime)
            }
            .onChange(of: playerVM.currentTime) { _, newTime in
                lyricsVM.updateActiveLine(currentTime: newTime)
            }
            .sheet(isPresented: $lyricsBinding.isShareModalPresented) {
                ShareLyricsModal()
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func ambientBackground(for track: Track) -> some View {
        AsyncImage(url: track.artworkURL) { phase in
            switch phase {
            case .success(let img):
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 80)
                    .overlay {
                        Color(hex: "0B0E14").opacity(0.88)
                    }
            default:
                Color(hex: "0B0E14")
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func headerView(track: Track) -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(track.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(track.artist)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()

            // Tombol Bagikan Lirik
            Button {
                lyricsVM.isShareModalPresented = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                    Text("Bagikan")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .liquidGlassCapsule(tint: Color.white.opacity(0.12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    @ViewBuilder
    private func bottomToolbar() -> some View {
        HStack(spacing: 16) {
            // Mini Player Status
            Button {
                playerVM.togglePlayPause()
            } label: {
                Image(systemName: playerVM.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(playerVM.formattedCurrentTime)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Text("Ketuk lirik untuk lompat waktu")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Button {
                lyricsVM.isShareModalPresented = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                    Text("Cerita IG")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color(hex: "E1306C")))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .liquidGlassCard(cornerRadius: 24, tint: Color(hex: "151A22").opacity(0.94))
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
    }
}
