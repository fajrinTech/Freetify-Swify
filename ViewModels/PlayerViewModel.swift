import Foundation
import SwiftUI
import Observation

/// ViewModel pengatur status pemutaran musik, antrean lagu, dan kontrol timeline
@Observable
@MainActor
public final class PlayerViewModel {
    public var queue: [Track] = []
    public var queueIndex: Int = 0

    public var isShuffleEnabled: Bool = false
    public var isRepeatEnabled: Bool = false

    public var isNowPlayingPresented: Bool = false
    public var isLyricsFullscreenPresented: Bool = false

    private let audioService = AudioPlayerService.shared
    private let cacheService = LocalCacheService.shared

    public init() {
        audioService.onTrackFinished = { [weak self] in
            self?.handleTrackFinished()
        }
        audioService.onRemoteNext = { [weak self] in
            self?.nextTrack()
        }
        audioService.onRemotePrevious = { [weak self] in
            self?.previousTrack()
        }
    }

    public var currentTrack: Track? {
        audioService.currentTrack
    }

    public var isPlaying: Bool {
        audioService.isPlaying
    }

    public var currentTime: TimeInterval {
        audioService.currentTime
    }

    public var duration: TimeInterval {
        audioService.duration
    }

    // MARK: - Playback Commands
    public func play(track: Track, inQueue: [Track]? = nil) {
        if let newQueue = inQueue, !newQueue.isEmpty {
            self.queue = newQueue
            if let index = newQueue.firstIndex(where: { $0.id == track.id }) {
                self.queueIndex = index
            } else {
                self.queueIndex = 0
            }
        } else {
            if let index = queue.firstIndex(where: { $0.id == track.id }) {
                self.queueIndex = index
            } else {
                self.queue = [track]
                self.queueIndex = 0
            }
        }
        audioService.loadAndPlay(track: track)
    }

    public func playQueue(tracks: [Track], startIndex: Int = 0) {
        guard !tracks.isEmpty else { return }
        self.queue = tracks
        self.queueIndex = max(0, min(startIndex, tracks.count - 1))
        let track = tracks[queueIndex]
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
        guard !fraction.isNaN && !fraction.isInfinite else { return }
        let clamped = max(0.0, min(fraction, 1.0))
        let targetTime = clamped * duration
        audioService.seek(to: targetTime)
    }

    public func seek(toSeconds seconds: TimeInterval) {
        guard !seconds.isNaN && !seconds.isInfinite else { return }
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
        audioService.loadAndPlay(track: track)
    }

    public func previousTrack() {
        guard !queue.isEmpty else { return }
        if currentTime > 3.0 {
            seek(toSeconds: 0)
        } else {
            queueIndex = (queueIndex - 1 + queue.count) % queue.count
            let track = queue[queueIndex]
            audioService.loadAndPlay(track: track)
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
            audioService.currentTrack?.isFavorite = isFav
        }
        if let idx = queue.firstIndex(where: { $0.id == track.id }) {
            queue[idx].isFavorite = isFav
        }
    }

    // MARK: - Computed Properties
    public var progress: Double {
        guard duration > 0 && !duration.isNaN && !duration.isInfinite && !currentTime.isNaN && !currentTime.isInfinite else {
            return 0.0
        }
        let value = currentTime / duration
        return min(max(value, 0.0), 1.0)
    }

    public var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    public var formattedRemainingTime: String {
        guard duration > 0 && !duration.isNaN && !currentTime.isNaN else { return "-0:00" }
        let remaining = max(0.0, duration - currentTime)
        return "-\(formatTime(remaining))"
    }

    public var formattedDuration: String {
        formatTime(duration)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && !time.isInfinite && time >= 0 else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
