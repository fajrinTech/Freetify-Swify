import SwiftUI
import Observation

/// Halaman Beranda Freetify iOS dengan tata letak Cyber Vinyl Studio & Lunkgem UI
public struct HomeView: View {
    @Environment(PlayerViewModel.self) private var playerVM
    @Environment(LibraryViewModel.self) private var libraryVM

    public var onOpenDrawer: (() -> Void)?

    @State private var selectedCategory: String = "all"
    @State private var searchQuery: String = ""

    private let categories: [(id: String, name: String, icon: String, color: String)] = [
        ("all", "Semua", "music.note", "3B82F6"),
        ("dj", "DJ Remix / JJ", "opticaldisc", "EC4899"),
        ("pop", "Pop Hits", "star.fill", "10B981"),
        ("rnb", "R&B / Soul", "heart.fill", "8B5CF6"),
        ("acoustic", "Acoustic", "leaf.fill", "F59E0B")
    ]

    public init(onOpenDrawer: (() -> Void)? = nil) {
        self.onOpenDrawer = onOpenDrawer
    }

    private var filteredTracks: [Track] {
        var list = libraryVM.allTracks
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchQuery.lowercased()
            list = list.filter {
                $0.title.lowercased().contains(q) ||
                $0.artist.lowercased().contains(q) ||
                $0.album.lowercased().contains(q)
            }
        }

        switch selectedCategory {
        case "dj":
            let djList = list.filter {
                $0.title.lowercased().contains("dj") ||
                $0.artist.lowercased().contains("dj") ||
                $0.album.lowercased().contains("tiktok")
            }
            return djList.isEmpty ? list : djList
        case "pop":
            let popList = list.filter {
                !$0.title.lowercased().contains("dj") &&
                !$0.artist.lowercased().contains("dj")
            }
            return popList.isEmpty ? list : popList
        default:
            return list
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background Gelap Cyber Midnight
                Color(hex: "0B0E14").ignoresSafeArea()

                VStack(spacing: 0) {
                    // 1. Fixed Header Row (Hamburger, Logo Freetify, Avatar)
                    headerBar()

                    // 2. Konten Scrollable
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 22) {
                            // Dark Search Bar
                            searchBarView()

                            // Filter Category Pills
                            categoryChipsView()

                            // Hero Section: Sedang Tren Saat Ini (Vinyl Hero Card)
                            if let heroTrack = filteredTracks.first {
                                heroTrendingSection(track: heroTrack)
                            }

                            // Section: Putar Ulang Vinyl (Horizontal Scroll)
                            vinylScrollSection()

                            // Section: Track Pilihan Minggu Ini
                            featuredTracksSection()

                            Spacer(minLength: 140)
                        }
                        .padding(.top, 12)
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
            // Tombol Hamburger Menu
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

            // Center Logo & Brand Name
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

            // User Avatar
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
    private func searchBarView() -> some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundColor(Color(hex: "8E8E93"))

            TextField("Search music...", text: $searchQuery)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .tint(Color(hex: "00F2FE"))

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "8E8E93"))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: "161B22"))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func categoryChipsView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.id) { cat in
                    let isSelected = selectedCategory == cat.id
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = cat.id
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 13, weight: .bold))
                            Text(cat.name)
                                .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                        }
                        .foregroundColor(isSelected ? .white : Color(hex: "94A3B8"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color(hex: cat.color))
                                    .shadow(color: Color(hex: cat.color).opacity(0.4), radius: 8, x: 0, y: 3)
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
        }
    }

    @ViewBuilder
    private func heroTrendingSection(track: Track) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sedang Tren Saat Ini")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            Button {
                playerVM.play(track: track)
            } label: {
                ZStack(alignment: .bottomLeading) {
                    // Background Hero Image dengan Ambient Gradient
                    AsyncImage(url: track.artworkURL) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            LinearGradient(
                                colors: [Color(hex: "1E293B"), Color(hex: "0F172A")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    }
                    .frame(height: 190)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color(hex: "0B0E14").opacity(0.4),
                                Color(hex: "0B0E14").opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }

                    // Content Overlay di Atas Hero Card
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PILIHAN EDITOR")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(Color(hex: "00F2FE"))
                                .tracking(1)

                            Text(track.title)
                                .font(.system(size: 22, weight: .heavy))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(track.artist)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }

                        Spacer()

                        // Play Circle Button Glowing
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "00F2FE"), Color(hex: "4FACFE")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 48, height: 48)
                                .shadow(color: Color(hex: "00F2FE").opacity(0.5), radius: 10, x: 0, y: 4)

                            Image(systemName: playerVM.currentTrack?.id == track.id && playerVM.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(18)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func vinylScrollSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Putar Ulang Vinyl")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(libraryVM.allTracks) { track in
                        Button {
                            playerVM.play(track: track)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                // Circular Vinyl Disc Card with Center Artwork
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "161B22"))
                                        .frame(width: 130, height: 130)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.2), .white.opacity(0.04)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
                                        )

                                    // Spindle Artwork Center
                                    AsyncImage(url: track.artworkURL) { phase in
                                        switch phase {
                                        case .success(let img):
                                            img.resizable().aspectRatio(contentMode: .fill)
                                        default:
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))

                                    // Vinyl Center Hole
                                    Circle()
                                        .fill(Color(hex: "0B0E14"))
                                        .frame(width: 14, height: 14)
                                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                }
                                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)

                                Text(track.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text(track.artist)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color(hex: "8B949E"))
                                    .lineLimit(1)
                            }
                            .frame(width: 130)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func featuredTracksSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Track Pilihan Minggu Ini")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(filteredTracks) { track in
                    Button {
                        playerVM.play(track: track)
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: track.artworkURL) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().aspectRatio(contentMode: .fill)
                                default:
                                    Color.gray.opacity(0.3)
                                }
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(track.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(playerVM.currentTrack?.id == track.id ? Color(hex: "00F2FE") : .white)
                                    .lineLimit(1)

                                HStack(spacing: 6) {
                                    Text("FLAC 24-bit")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundColor(Color(hex: "00F2FE"))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(Color(hex: "00F2FE").opacity(0.12)))

                                    Text(track.artist)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(hex: "8B949E"))
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            Button {
                                playerVM.toggleFavorite(for: track)
                            } label: {
                                Image(systemName: track.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 18))
                                    .foregroundColor(track.isFavorite ? Color(hex: "00F2FE") : Color(hex: "8B949E"))
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(hex: "161B22"))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                                }
                        }
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
