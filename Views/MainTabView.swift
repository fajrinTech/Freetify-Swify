import SwiftUI
import Observation

/// Kontainer navigasi tab utama aplikasi Freetify dengan gesture swipe antar halaman, Sidebar Drawer, Floating Mini Player, dan Liquid Glass Tab Bar
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
            // Konten Halaman Swipeable Paging (Bisa digeser kiri-kanan secara mulus)
            TabView(selection: $selectedTab) {
                HomeView(onOpenDrawer: { isDrawerPresented = true })
                    .tag(TabItem.home)

                SearchView(onOpenDrawer: { isDrawerPresented = true })
                    .tag(TabItem.search)

                LibraryView(onOpenDrawer: { isDrawerPresented = true })
                    .tag(TabItem.library)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)

            // Floating Mini Player & Glass Tab Bar di Bagian Bawah
            VStack(spacing: 8) {
                if playerVM.currentTrack != nil {
                    MiniPlayerView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                LiquidGlassTabBar(selectedTab: $selectedTab)
                    .frame(height: 72)
            }
            .padding(.bottom, 8)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: playerVM.currentTrack != nil)

            // Sidebar Drawer Navigasi
            SidebarDrawerView(isPresented: $isDrawerPresented)
        }
        .task {
            await libraryVM.loadLibrary()
        }
        .sheet(isPresented: $playerBinding.isNowPlayingPresented) {
            NowPlayingView()
        }
    }
}
