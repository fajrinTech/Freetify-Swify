import SwiftUI

/// Kontainer navigasi tab utama aplikasi Freetify dengan Sidebar Drawer, Floating Mini Player, dan Liquid Glass Tab Bar
public struct MainTabView: View {
    @Environment(PlayerViewModel.self) private var playerVM
    @Environment(LibraryViewModel.self) private var libraryVM
    @Environment(LyricsViewModel.self) private var lyricsVM

    @State private var selectedTab: TabItem = .home
    @State private var isDrawerPresented: Bool = false

    public init() {}

    public var body: some View {
        @Bindable var playerBinding = playerVM

        ZStack(alignment: .bottom) {
            // Konten Halaman Sesuai Tab Aktif
            Group {
                switch selectedTab {
                case .home:
                    HomeView(onOpenDrawer: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isDrawerPresented = true
                        }
                    })
                case .search:
                    SearchView(onOpenDrawer: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isDrawerPresented = true
                        }
                    })
                case .library:
                    LibraryView(onOpenDrawer: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isDrawerPresented = true
                        }
                    })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Overlay Bagian Bawah: Floating MiniPlayer + Floating Liquid Glass TabBar
            VStack(spacing: 10) {
                // Mini Player jika sedang memutar lagu
                MiniPlayerView()

                // Liquid Glass Tab Bar
                LiquidGlassTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 2)

            // Overlay Sidebar Drawer Menu Navigasi
            SidebarDrawerView(isPresented: $isDrawerPresented)
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $playerBinding.isNowPlayingPresented) {
            NowPlayingView()
        }
        .task {
            // Muat pustaka lagu saat aplikasi dibuka
            await libraryVM.loadLibrary()
            if playerVM.currentTrack == nil, let firstTrack = libraryVM.allTracks.first {
                playerVM.queue = libraryVM.allTracks
                playerVM.currentTrack = firstTrack
            }
        }
    }
}
