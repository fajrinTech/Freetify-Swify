import Foundation
import SwiftUI
import Observation

/// ViewModel pengatur katalog lagu, sinkronisasi Supabase, dan daftar lagu favorit
@Observable
@MainActor
public final class LibraryViewModel {
    public var allTracks: [Track] = []
    public var favoriteTracks: [Track] = []
    public var searchQuery: String = ""
    public var isLoading: Bool = false

    private let supabaseService = SupabaseService.shared
    private let cacheService = LocalCacheService.shared

    public init() {
        self.allTracks = Track.samples
        refreshFavorites()
        Task { [weak self] in
            await self?.loadLibrary()
        }
    }

    public func loadLibrary() async {
        isLoading = true
        do {
            let fetched = try await supabaseService.fetchSongs()
            if !fetched.isEmpty {
                self.allTracks = fetched
            }
        } catch {
            print("[LibraryViewModel] Error loading songs: \(error.localizedDescription)")
        }
        refreshFavorites()
        isLoading = false
    }

    public func refreshFavorites() {
        let favIDs = cacheService.getFavoriteIDs()
        for i in 0..<allTracks.count {
            allTracks[i].isFavorite = favIDs.contains(allTracks[i].id)
        }
        favoriteTracks = allTracks.filter { $0.isFavorite }
    }

    public var filteredTracks: [Track] {
        if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            return allTracks
        }
        let query = searchQuery.lowercased()
        return allTracks.filter {
            $0.title.lowercased().contains(query) ||
            $0.artist.lowercased().contains(query) ||
            $0.album.lowercased().contains(query)
        }
    }
}
