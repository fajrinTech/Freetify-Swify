import SwiftUI
import Observation

/// Halaman Koleksi Freetify iOS dengan filter pills, sort bar, dan daftar lagu favorit
public struct LibraryView: View {
    @Environment(PlayerViewModel.self) private var playerVM
    @Environment(LibraryViewModel.self) private var libraryVM

    public var onOpenDrawer: (() -> Void)?

    @State private var selectedPill: String? = nil
    private let pills = ["Playlists", "Artis", "Album", "Favorit"]

    public init(onOpenDrawer: (() -> Void)? = nil) {
        self.onOpenDrawer = onOpenDrawer
    }

    private var displayedTracks: [Track] {
        if selectedPill == "Favorit" {
            return libraryVM.favoriteTracks
        }
        return libraryVM.allTracks
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0B0E14").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header Bar (Hamburger, Logo, Avatar)
                    headerBar()

                    // Filter Pills Row
                    filterPillsRow()

                    // Sub-Header Sort Row
                    sortRow()

                    // Daftar Lagu / Playlist
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(displayedTracks) { track in
                                Button {
                                    playerVM.play(track: track)
                                } label: {
                                    HStack(spacing: 14) {
                                        AsyncImage(url: track.artworkURL) { phase in
                                            switch phase {
                                            case .success(let img):
                                                img.resizable().aspectRatio(contentMode: .fill)
                                            default:
                                                Color.gray.opacity(0.3)
                                            }
                                        }
                                        .frame(width: 52, height: 52)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(track.title)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                                .lineLimit(1)

                                            Text("Lagu • \(track.artist)")
                                                .font(.system(size: 13, weight: .regular))
                                                .foregroundColor(Color(hex: "8B949E"))
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        Button {
                                            playerVM.toggleFavorite(for: track)
                                            libraryVM.refreshFavorites()
                                        } label: {
                                            Image(systemName: track.isFavorite ? "heart.fill" : "heart")
                                                .font(.system(size: 20))
                                                .foregroundColor(track.isFavorite ? Color(hex: "00F2FE") : Color(hex: "64748B"))
                                                .frame(width: 36, height: 36)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(.plain)
                            }

                            Spacer(minLength: 140)
                        }
                        .padding(.top, 8)
                    }
                    .refreshable {
                        await libraryVM.loadLibrary()
                    }
                    .task {
                        await libraryVM.loadLibrary()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func headerBar() -> some View {
        HStack {
            Button {
                onOpenDrawer?()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "00F2FE"), Color(hex: "7F00FF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Freetify")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(0.5)
            }

            Spacer()

            AsyncImage(url: UserProfile.sample.avatarURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().aspectRatio(contentMode: .fill)
                default:
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(width: 38, height: 38)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(hex: "0B0E14"))
    }

    @ViewBuilder
    private func filterPillsRow() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(pills, id: \.self) { pill in
                    let isSelected = selectedPill == pill
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedPill = isSelected ? nil : pill
                        }
                    } label: {
                        Text(pill)
                            .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                            .foregroundColor(isSelected ? .white : Color(hex: "94A3B8"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                if isSelected {
                                    Capsule()
                                        .fill(Color(hex: "3B82F6"))
                                } else {
                                    Capsule()
                                        .fill(Color(hex: "161B22"))
                                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func sortRow() -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 12, weight: .bold))
                Text("Urutkan berdasarkan Terbaru")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(Color(hex: "94A3B8"))

            Spacer()

            Image(systemName: "square.grid.2x2")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "94A3B8"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}
