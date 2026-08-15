import Foundation
import SwiftUI
import Observation

/// ViewModel pengatur status pemutaran musik, antrean lagu, dan kontrol timeline
@Observable
@MainActor
public final class PlayerViewModel {
    public var currentTrack: Track?
    public var queue: [Track] = []
    public var queueIndex: Int = 0

    public var isPlaying: Bool = false
    public var currentTime: TimeInterval = 0
    public var duration: TimeInterval = 1.0

    public var isShuffleEnabled: Bool = false
    public var isRepeatEnabled: Bool = false

    public var isNowPlayingPresented: Bool = false
    public var isLyricsFullscreenPresented: Bool = false

    private let audioService = AudioPlayerService.shared
    private let cacheService = LocalCacheService.shared

    public init() {
        setupBindings()
    }

    private func setupBindings() {
        audioService.onTimeUpdate = { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time
        }

        audioService.onDurationUpdate = { [weak self] dur in
            guard let self = self, dur > 0 else { return }
            self.duration = dur
        }

        audioService.onPlaybackStateChanged = { [weak self] playing in
            guard let self = self else { return }
            self.isPlaying = playing
        }

        audioService.onTrackFinished = { [weak self] in
            guard let self = self else { return }
            self.handleTrackFinished()
        }
    }

    // MARK: - Playback Commands
    public func play(track: Track) {
        if let index = queue.firstIndex(where: { $0.id == track.id }) {
            queueIndex = index
        } else {
            queue = [track]
            queueIndex = 0
        }
        currentTrack = track
        duration = track.duration > 0 ? track.duration : 1.0
        currentTime = 0
        audioService.loadAndPlay(track: track)
    }

    public func playQueue(tracks: [Track], startIndex: Int = 0) {
        guard !tracks.isEmpty else { return }
        self.queue = tracks
        self.queueIndex = max(0, min(startIndex, tracks.count - 1))
        let track = tracks[queueIndex]
        self.currentTrack = track
        self.duration = track.duration > 0 ? track.duration : 1.0
        self.currentTime = 0
        audioService.loadAndPlay(track: track)
    }

    public func togglePlayPause() {
        if currentTrack == nil, let first = queue.first {
            play(track: first)
        } else {
            audioService.togglePlayPause()
        }
    }

    public func seek(toFraction fraction: Double) {
        let clamped = max(0.0, min(fraction, 1.0))
        let targetTime = clamped * duration
        audioService.seek(to: targetTime)
    }

    public func seek(toSeconds seconds: TimeInterval) {
        let clamped = max(0.0, min(seconds, duration))
        audioService.seek(to: clamped)
    }

    public func nextTrack() {
        guard !queue.isEmpty else { return }
        if isShuffleEnabled {
            queueIndex = Int.random(in: 0..<queue.count)
        } else {
            queueIndex = (queueIndex + 1) % queue.count
        }
        let track = queue[queueIndex]
        play(track: track)
    }

    public func previousTrack() {
        guard !queue.isEmpty else { return }
        if currentTime > 3.0 {
            seek(toSeconds: 0)
        } else {
            queueIndex = (queueIndex - 1 + queue.count) % queue.count
            let track = queue[queueIndex]
            play(track: track)
        }
    }

    private func handleTrackFinished() {
        if isRepeatEnabled {
            seek(toSeconds: 0)
            audioService.play()
        } else {
            nextTrack()
        }
    }

    public func toggleShuffle() {
        isShuffleEnabled.toggle()
    }

    public func toggleRepeat() {
        isRepeatEnabled.toggle()
    }

    public func toggleFavorite(for track: Track) {
        let isFav = cacheService.toggleFavorite(trackID: track.id)
        if currentTrack?.id == track.id {
            currentTrack?.isFavorite = isFav
        }
        if let idx = queue.firstIndex(where: { $0.id == track.id }) {
            queue[idx].isFavorite = isFav
        }
    }

    // MARK: - Computed Properties
    public var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0.0), 1.0)
    }

    public var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    public var formattedRemainingTime: String {
        let remaining = max(0, duration - currentTime)
        return "-\(formatTime(remaining))"
    }

    public var formattedDuration: String {
        formatTime(duration)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
