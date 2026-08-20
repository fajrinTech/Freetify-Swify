import SwiftUI
import Observation

/// Kontainer navigasi tab utama aplikasi Freetify dengan gesture swipe antar halaman, Sidebar Drawer, Floating Mini Player, dan Frosted Glass Docking
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
            // 1. Konten Halaman Swipeable Paging (Bisa digeser kiri-kanan secara mulus)
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

            // 2. Frosted Ambient Bottom Blur Backdrop (Membuat konten yang di-scroll memudar halus di bawah tab bar)
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(hex: "080B10").opacity(0.60),
                        Color(hex: "080B10").opacity(0.92),
                        Color(hex: "080B10")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: playerVM.currentTrack != nil ? 180 : 120)
                .background(.ultraThinMaterial.opacity(0.35))
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: playerVM.currentTrack != nil)

            // 3. Floating Mini Player & Glass Tab Bar di Bagian Bawah
            VStack(spacing: 6) {
                if playerVM.currentTrack != nil {
                    MiniPlayerView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                LiquidGlassTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 2)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: playerVM.currentTrack != nil)

            // 4. Sidebar Drawer Navigasi
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
