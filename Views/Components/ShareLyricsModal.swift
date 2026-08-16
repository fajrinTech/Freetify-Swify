import SwiftUI
import UIKit

/// Modal pratinjau dan kustomisasi kartu stiker lirik sebelum dibagikan ke Instagram Stories / disimpan ke Galeri
public struct ShareLyricsModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LyricsViewModel.self) private var lyricsVM
    @Environment(PlayerViewModel.self) private var playerVM

    @State private var showSavedToast: Bool = false
    @State private var saveErrorMessage: String? = nil

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
                                .foregroundColor(Color(hex: "00F2FE"))
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
                                                .foregroundColor(isSelected ? Color(hex: "00F2FE") : .white.opacity(0.3))
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
                    .padding(.bottom, 120)
                }

                // Toast Notifikasi Tersimpan di Galeri
                if showSavedToast {
                    VStack {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "00F2FE"))
                                .font(.system(size: 20))
                            Text("Tersimpan di Galeri Foto")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color(hex: "1F2937").opacity(0.95)))
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
                        .padding(.top, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))

                        Spacer()
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showSavedToast)
                }

                // Bottom Action Bar: Tombol Simpan Foto & Tombol Bagikan
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        // Tombol 1: Simpan ke Galeri Foto
                        Button {
                            saveImageToPhotos()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down.to.line.compact")
                                    .font(.system(size: 15, weight: .bold))
                                Text("Simpan Foto")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                                    )
                            }
                        }
                        .disabled(lyricsVM.selectedLines.isEmpty)
                        .opacity(lyricsVM.selectedLines.isEmpty ? 0.4 : 1.0)

                        // Tombol 2: Universal iOS Share Sheet
                        Button {
                            presentNativeShareSheet()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .bold))
                                Text("Bagikan...")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "E1306C"), Color(hex: "833AB4")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .shadow(color: Color(hex: "E1306C").opacity(0.4), radius: 10, x: 0, y: 4)
                            }
                        }
                        .disabled(lyricsVM.selectedLines.isEmpty)
                        .opacity(lyricsVM.selectedLines.isEmpty ? 0.4 : 1.0)
                    }
                    .padding(.horizontal, 20)
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
        }
    }

    // MARK: - Actions
    @MainActor
    private func renderLyricImage() -> UIImage? {
        guard let track = playerVM.currentTrack else { return nil }

        let stickerView = LyricsStickerPreviewCard(
            track: track,
            lines: lyricsVM.selectedLines,
            palette: lyricsVM.selectedPalette
        )
        .frame(width: 340)

        let renderer = ImageRenderer(content: stickerView)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    @MainActor
    private func saveImageToPhotos() {
        guard let image = renderLyricImage() else { return }

        let photoSaver = PhotoSaver()
        photoSaver.onSuccess = {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation {
                showSavedToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSavedToast = false
                }
            }
        }
        photoSaver.save(image: image)
    }

    @MainActor
    private func presentNativeShareSheet() {
        guard let image = renderLyricImage() else { return }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }

            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topVC.view
                popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            topVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - PhotoSaver Helper
final class PhotoSaver: NSObject {
    var onSuccess: (() -> Void)?

    func save(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            DispatchQueue.main.async {
                self.onSuccess?()
            }
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
