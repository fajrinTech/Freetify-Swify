import SwiftUI

/// Modal pratinjau dan kustomisasi kartu stiker lirik sebelum dibagikan ke Instagram Stories
public struct ShareLyricsModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LyricsViewModel.self) private var lyricsVM
    @Environment(PlayerViewModel.self) private var playerVM

    @State private var showConfirmAlert: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0D0E12").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header Instruksi
                        VStack(spacing: 6) {
                            Text("Pilih hingga 5 baris lirik")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))

                            Text("\(lyricsVM.selectedLines.count)/5 baris dipilih")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "1DB954"))
                        }
                        .padding(.top, 8)

                        // Kartu Pratinjau Stiker
                        if let track = playerVM.currentTrack {
                            LyricsStickerPreviewCard(
                                track: track,
                                lines: lyricsVM.selectedLines,
                                palette: lyricsVM.selectedPalette
                            )
                            .frame(maxWidth: 340)
                            .padding(.horizontal, 16)
                        }

                        // Pemilih Palet Warna
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PILIH WARNA TEMA")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(SharePalette.palettes) { palette in
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                lyricsVM.selectedPalette = palette
                                            }
                                        } label: {
                                            Circle()
                                                .fill(palette.gradient)
                                                .frame(width: 44, height: 44)
                                                .overlay {
                                                    if lyricsVM.selectedPalette.id == palette.id {
                                                        Circle()
                                                            .strokeBorder(Color.white, lineWidth: 3)
                                                            .padding(2)
                                                    }
                                                }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        // Daftar Baris Lirik untuk Dipilih
                        VStack(alignment: .leading, spacing: 10) {
                            Text("KETUK BARIS UNTUK MEMILIH")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 24)

                            VStack(spacing: 8) {
                                ForEach(lyricsVM.lines) { line in
                                    let isSelected = lyricsVM.isLineSelected(line)
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            lyricsVM.toggleLineSelection(line)
                                        }
                                    } label: {
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 18))
                                                .foregroundColor(isSelected ? Color(hex: "1DB954") : .white.opacity(0.3))
                                                .padding(.top, 2)

                                            Text(line.text)
                                                .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                                                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                                                .multilineTextAlignment(.leading)

                                            Spacer()
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 14)
                                        .background {
                                            if isSelected {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.white.opacity(0.08))
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 100)
                }

                // Floating Action Button di Bawah: "Cerita IG"
                VStack {
                    Spacer()
                    Button {
                        showConfirmAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Cerita IG")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background {
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "E1306C"), Color(hex: "833AB4")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        }
                        .padding(.horizontal, 24)
                        .shadow(color: Color(hex: "E1306C").opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .disabled(lyricsVM.selectedLines.isEmpty)
                    .opacity(lyricsVM.selectedLines.isEmpty ? 0.5 : 1.0)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Bagikan Lirik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Buka Instagram?", isPresented: $showConfirmAlert) {
                Button("Buka", role: .none) {
                    exportAndShareToInstagram()
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Freetify ingin membuka aplikasi Instagram untuk membagikan kartu lirik ke Cerita Anda.")
            }
        }
    }

    @MainActor
    private func exportAndShareToInstagram() {
        guard let track = playerVM.currentTrack else { return }

        // Render View menjadi Gambar UIImage
        let stickerView = LyricsStickerPreviewCard(
            track: track,
            lines: lyricsVM.selectedLines,
            palette: lyricsVM.selectedPalette
        )
        .frame(width: 320)

        let renderer = ImageRenderer(content: stickerView)
        renderer.scale = UIScreen.main.scale

        if let image = renderer.uiImage {
            InstagramShareService.shared.shareLyricsToInstagramStories(
                stickerImage: image,
                palette: lyricsVM.selectedPalette,
                track: track
            )
            dismiss()
        }
    }
}

// MARK: - Subview: Lyrics Sticker Card
public struct LyricsStickerPreviewCard: View {
    public let track: Track
    public let lines: [LyricLine]
    public let palette: SharePalette

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header: Judul Lagu, Artis & Logo Freetify
            HStack(alignment: .top) {
                HStack(spacing: 10) {
                    AsyncImage(url: track.artworkURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Color.black.opacity(0.3)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(palette.primaryTextColor)
                            .lineLimit(1)

                        Text(track.artist)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(palette.secondaryTextColor)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Badge Logo Freetify
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.system(size: 11, weight: .bold))
                    Text("Freetify")
                        .font(.system(size: 11, weight: .heavy))
                }
                .foregroundColor(palette.primaryTextColor.opacity(0.8))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.white.opacity(0.15)))
            }

            // Teks Lirik yang Dipilih
            if lines.isEmpty {
                Text("Pilih baris lirik di bawah untuk menampilkannya pada kartu...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(palette.secondaryTextColor.opacity(0.8))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(lines) { line in
                        Text(line.text)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(palette.primaryTextColor)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(palette.gradient)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
    }
}
