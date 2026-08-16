import SwiftUI
import Observation

/// Titik masuk utama aplikasi Freetify iOS (@main) dengan transisi Splash Screen animasi
@main
struct FreetifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var playerVM = PlayerViewModel()
    @State private var libraryVM = LibraryViewModel()
    @State private var lyricsVM = LyricsViewModel()
    @State private var isSplashScreenActive: Bool = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environment(playerVM)
                    .environment(libraryVM)
                    .environment(lyricsVM)

                if isSplashScreenActive {
                    SplashScreenView()
                        .transition(.opacity.combined(with: .scale(scale: 1.04)))
                        .zIndex(999)
                }
            }
            .preferredColorScheme(.dark)
            .task {
                // Beri waktu 1.3 detik untuk animasi splash screen pembuka & preload database
                try? await Task.sleep(nanoseconds: 1_300_000_000)
                withAnimation(.easeInOut(duration: 0.45)) {
                    isSplashScreenActive = false
                }
            }
        }
    }
}
