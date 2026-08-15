import SwiftUI

/// Halaman Pencarian Freetify dengan header profil Lunkgem, pencarian user profil, dan kategori Supabase
public struct SearchView: View {
    @Environment(PlayerViewModel.self) private var playerVM
    @Environment(LibraryViewModel.self) private var libraryVM

    public var onOpenDrawer: (() -> Void)?

    private let genreCards: [(title: String, color: String, badge: String)] = [
        ("Top Hits Pop", "1E293B", "SUPABASE DB"),
        ("Indonesia", "1E2530", "SUPABASE DB"),
        ("Acoustic Chill", "1B212A", "SUPABASE DB"),
        ("DJ Remix", "1F2937", "SUPABASE DB"),
        ("R&B / Soul", "1E293B", "SUPABASE DB"),
        ("Nostalgia", "1E2530", "SUPABASE DB")
    ]

    public init(onOpenDrawer: (() -> Void)? = nil) {
        self.onOpenDrawer = onOpenDrawer
    }

    public var body: some View {
        @Bindable var libVM = libraryVM

        NavigationStack {
            ZStack {
                Color(hex: "0B0E14").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header Bar (Hamburger, Logo, Avatar)
                    headerBar()

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            // Dark Search Bar
                            searchBarView(libVM: libVM)

                            if libVM.searchQuery.isEmpty {
                                // Default View: Genre Cards Grid
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Jelajahi Kategori")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)

                                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                        ForEach(genreCards, id: \.title) { card in
                                            Button {
                                                libVM.searchQuery = card.title
                                            } label: {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text(card.badge)
                                                        .font(.system(size: 9, weight: .heavy))
                                                        .foregroundColor(Color(hex: "00F2FE"))
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Capsule().fill(Color(hex: "00F2FE").opacity(0.12)))

                                                    Spacer()

                                                    Text(card.title)
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .frame(height: 90)
                                                .padding(14)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                        .fill(Color(hex: card.color))
                                                        .overlay {
                                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                                        }
                                                }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            } else {
                                // Hasil Pencarian Profil Pengguna
                                userProfileSearchResultSection(query: libVM.searchQuery)

                                // Hasil Pencarian Lagu
                                songResultsSection(libVM: libVM)
                            }

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
    private func searchBarView(libVM: LibraryViewModel) -> some View {
        @Bindable var vm = libVM
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundColor(Color(hex: "8E8E93"))

            TextField("Cari judul, artis, atau profil...", text: $vm.searchQuery)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .tint(Color(hex: "00F2FE"))

            if !vm.searchQuery.isEmpty {
                Button {
                    vm.searchQuery = ""
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
    private func userProfileSearchResultSection(query: String) -> some View {
        if query.lowercased().contains("fajrin") || query.lowercased().contains("ceo") || query.lowercased().contains("user") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Profil")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "94A3B8"))
                    .padding(.horizontal, 20)

                HStack(spacing: 14) {
                    AsyncImage(url: UserProfile.sample.avatarURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hex: "00F2FE"), lineWidth: 1.5))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Fajrin Widianto")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)

                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(hex: "00F2FE"))
                                .font(.system(size: 14))
                        }

                        Text("CEO & Founder of Freetify • 5M Pengikut")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "10B981"))
                    }

                    Spacer()
                }
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: "161B22"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func songResultsSection(libVM: LibraryViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lagu (\(libVM.filteredTracks.count))")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "94A3B8"))
                .padding(.horizontal, 20)

            if libVM.filteredTracks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "music.note.slash")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.3))
                    Text("Lagu tidak ditemukan")
                        .foregroundColor(Color(hex: "8B949E"))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
            } else {
                VStack(spacing: 8) {
                    ForEach(libVM.filteredTracks) { track in
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
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(track.title)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Text(track.artist)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(Color(hex: "8B949E"))
                                        .lineLimit(1)
                                }

                                Spacer()

                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "00F2FE"))
                            }
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(hex: "161B22"))
                            }
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
