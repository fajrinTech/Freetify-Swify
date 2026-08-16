import SwiftUI
import Observation

/// Layanan Layar Pemutar Musik Penuh (Now Playing Screen) dengan desain Cyber Vinyl Studio & Ambient Blur
public struct NowPlayingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerViewModel.self) private var playerVM
    @Environment(LyricsViewModel.self) private var lyricsVM

    @State private var isDraggingSlider: Bool = false
    @State private var sliderFraction: Double = 0.0

    public init() {}

    public var body: some View {
        @Bindable var playerBinding = playerVM
        @Bindable var lyricsBinding = lyricsVM

        if let track = playerVM.currentTrack {
            ZStack {
                // 1. Ambient Dynamic Artwork Background
                ambientBackground(for: track)

                // 2. Konten Scrollable
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Top Bar: Dismiss Chevron, Judul Album/Playlist, Tombol Favorit
                        topBar(track: track)

                        // Artwork Utama HD
                        mainArtwork(track: track)

                        // Info Judul Lagu, Artis & Tombol Bagikan Lirik
                        trackInfoSection(track: track)

                        // Timeline Seekbar Slider
                        timelineScrubber()

                        // Kontrol Pemutaran (Shuffle, Prev, Big Play/Pause, Next, Repeat)
                        playbackControls()

                        // Device Status (TWS Audio) & Quick Actions
                        deviceAndActionsToolbar()

                        // Kartu Pratinjau Lirik Singkat
                        lyricsPreviewCard(track: track)

                        // Kartu Profil Tentang Artis
                        ArtistCardView(track: track)
                            .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 10)
                }
            }
            .task {
                await lyricsVM.loadLyrics(for: track)
            }
            .onChange(of: playerVM.currentTime) { _, newTime in
                lyricsVM.updateActiveLine(currentTime: newTime)
            }
            .sheet(isPresented: $playerBinding.isLyricsFullscreenPresented) {
                FullscreenLyricsView()
            }
            .sheet(isPresented: $lyricsBinding.isShareModalPresented) {
                ShareLyricsModal()
            }
        }
    }

    // MARK: - Subviews & Sections

    @ViewBuilder
    private func ambientBackground(for track: Track) -> some View {
        GeometryReader { _ in
            AsyncImage(url: track.artworkURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blur(radius: 60)
                        .overlay {
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.4),
                                    Color(hex: "0B0E14").opacity(0.85),
                                    Color(hex: "0B0E14")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                default:
                    Color(hex: "0B0E14")
                }
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func topBar(track: Track) -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("MEMUTAR DARI PLAYLIST")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "8B949E"))
                    .tracking(0.8)

                Text(track.album)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                playerVM.toggleFavorite(for: track)
            } label: {
                Image(systemName: track.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(track.isFavorite ? Color(hex: "00F2FE") : .white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func mainArtwork(track: Track) -> some View {
        AsyncImage(url: track.artworkURL) { phase in
            switch phase {
            case .success(let img):
                img
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            default:
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 64))
                            .foregroundColor(.white.opacity(0.4))
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 12)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func trackInfoSection(track: Track) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(track.artist)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "8B949E"))
                    .lineLimit(1)
            }

            Spacer()

            Button {
                lyricsVM.isShareModalPresented = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 19))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func timelineScrubber() -> some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let currentFraction = isDraggingSlider ? sliderFraction : playerVM.progress
                let safeFraction = max(0.0, min(currentFraction.isNaN ? 0.0 : currentFraction, 1.0))
                let safeWidth = max(0.0, min(geo.size.width * CGFloat(safeFraction), geo.size.width))

                ZStack(alignment: .leading) {
                    // Background Bar
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)

                    // Active Progress Bar with Cyan Tint
                    Capsule()
                        .fill(Color(hex: "00F2FE"))
                        .frame(width: safeWidth, height: 4)
                }
                .frame(height: 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard geo.size.width > 0 else { return }
                            isDraggingSlider = true
                            let rawFraction = value.location.x / geo.size.width
                            sliderFraction = max(0.0, min(rawFraction.isNaN ? 0.0 : rawFraction, 1.0))
                        }
                        .onEnded { value in
                            guard geo.size.width > 0 else { return }
                            let rawFraction = value.location.x / geo.size.width
                            let target = max(0.0, min(rawFraction.isNaN ? 0.0 : rawFraction, 1.0))
                            playerVM.seek(toFraction: target)
                            isDraggingSlider = false
                        }
                )
            }
            .frame(height: 20)

            HStack {
                Text(playerVM.formattedCurrentTime)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "8B949E"))

                Spacer()

                Text(playerVM.formattedRemainingTime)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "8B949E"))
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func playbackControls() -> some View {
        HStack(spacing: 0) {
            // Shuffle
            Button {
                playerVM.toggleShuffle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(playerVM.isShuffleEnabled ? Color(hex: "00F2FE") : Color(hex: "8B949E"))
                    .frame(maxWidth: .infinity)
            }

            // Previous
            Button {
                playerVM.previousTrack()
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }

            // Big White Play / Pause Circle
            Button {
                playerVM.togglePlayPause()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 68, height: 68)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)

                    Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
            }

            // Next
            Button {
                playerVM.nextTrack()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }

            // Repeat
            Button {
                playerVM.toggleRepeat()
            } label: {
                Image(systemName: "repeat")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(playerVM.isRepeatEnabled ? Color(hex: "00F2FE") : Color(hex: "8B949E"))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func deviceAndActionsToolbar() -> some View {
        HStack {
            // Status Device Output (AirPlay / TWS)
            HStack(spacing: 6) {
                Image(systemName: "airpodspro")
                    .font(.system(size: 14))
                Text("Fajrin AirPods Pro")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(Color(hex: "00F2FE"))

            Spacer()

            // Tombol Antrean Musik
            Button {
                // Queue view
            } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func lyricsPreviewCard(track: Track) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Lirik")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                // Tombol Kapsul Putih: "Tampilkan lirik"
                Button {
                    playerVM.isLyricsFullscreenPresented = true
                } label: {
                    Text("Tampilkan lirik")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.white))
                }
            }

            if lyricsVM.lines.isEmpty {
                Text("Lirik tidak tersedia untuk lagu ini.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                let activeIdx = lyricsVM.activeLineIndex
                let previewLines = lyricsVM.lines.prefix(3)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(previewLines.enumerated()), id: \.element.id) { idx, line in
                        Text(line.text)
                            .font(.system(size: 17, weight: idx == activeIdx ? .heavy : .medium))
                            .foregroundColor(idx == activeIdx ? .white : .white.opacity(0.4))
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(20)
        .liquidGlassCard(cornerRadius: 24, tint: Color(hex: "161B22").opacity(0.88))
        .padding(.horizontal, 20)
    }
}
