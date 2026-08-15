import SwiftUI

/// Titik masuk utama aplikasi Freetify iOS (@main)
@main
struct FreetifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var playerVM = PlayerViewModel()
    @State private var libraryVM = LibraryViewModel()
    @State private var lyricsVM = LyricsViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(playerVM)
                .environment(libraryVM)
                .environment(lyricsVM)
                .preferredColorScheme(.dark)
        }
    }
}
