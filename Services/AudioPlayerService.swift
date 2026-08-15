import Foundation
import AVFoundation
import MediaPlayer
import UIKit

/// Layanan inti pemutar audio native iOS dengan dukungan Background Mode, Lock Screen, dan Remote Commands
@MainActor
public final class AudioPlayerService: NSObject {
    public static let shared = AudioPlayerService()

    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var itemEndObserver: Any?

    public var onTimeUpdate: ((TimeInterval) -> Void)?
    public var onDurationUpdate: ((TimeInterval) -> Void)?
    public var onPlaybackStateChanged: ((Bool) -> Void)?
    public var onTrackFinished: (() -> Void)?

    private(set) var currentTrack: Track?
    public private(set) var isPlaying: Bool = false
    public private(set) var currentTime: TimeInterval = 0
    public private(set) var duration: TimeInterval = 0

    override private init() {
        super.init()
        setupAudioSession()
        setupRemoteCommands()
    }

    deinit {
        removeTimeObserver()
        if let itemEndObserver = itemEndObserver {
            NotificationCenter.default.removeObserver(itemEndObserver)
        }
    }

    // MARK: - Audio Session Setup
    public func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch {
            print("[AudioPlayerService] Failed to set AVAudioSession category: \(error.localizedDescription)")
        }
    }

    // MARK: - Playback Controls
    public func loadAndPlay(track: Track) {
        self.currentTrack = track
        self.duration = track.duration

        removeTimeObserver()

        // Prioritaskan file audio lokal jika sudah di-cache
        let playbackURL = track.cachedLocalAudioURL ?? track.audioURL
        let playerItem = AVPlayerItem(url: playbackURL)

        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }

        setupTimeObserver()
        setupItemEndObserver(for: playerItem)

        play()
        updateNowPlayingInfo(track: track)
    }

    public func play() {
        player?.play()
        isPlaying = true
        onPlaybackStateChanged?(true)
        updatePlaybackStateInNowPlaying()
    }

    public func pause() {
        player?.pause()
        isPlaying = false
        onPlaybackStateChanged?(false)
        updatePlaybackStateInNowPlaying()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    public func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentTime = time
                self.onTimeUpdate?(time)
                self.updatePlaybackStateInNowPlaying()
            }
        }
    }

    // MARK: - Periodic Time Observer
    private func setupTimeObserver() {
        // Observasi setiap 50 milidetik untuk sinkronisasi lirik yang sangat mulus
        let interval = CMTime(seconds: 0.05, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self = self else { return }
                let seconds = CMTimeGetSeconds(time)
                if !seconds.isNaN && !seconds.isInfinite {
                    self.currentTime = seconds
                    self.onTimeUpdate?(seconds)

                    // Update durasi aktual jika tersedia dari AVPlayerItem
                    if let currentItem = self.player?.currentItem {
                        let itemDuration = CMTimeGetSeconds(currentItem.duration)
                        if !itemDuration.isNaN && !itemDuration.isInfinite && itemDuration > 0 {
                            self.duration = itemDuration
                            self.onDurationUpdate?(itemDuration)
                        }
                    }
                }
            }
        }
    }

    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    private func setupItemEndObserver(for item: AVPlayerItem) {
        if let itemEndObserver = itemEndObserver {
            NotificationCenter.default.removeObserver(itemEndObserver)
        }

        itemEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.onTrackFinished?()
            }
        }
    }

    // MARK: - MPNowPlayingInfoCenter (Lock Screen & Dynamic Island)
    private func updateNowPlayingInfo(track: Track) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyAlbumTitle: track.album,
            MPMediaItemPropertyPlaybackDuration: track.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        // Load Artwork secara asinkron
        if let artworkURL = track.artworkURL {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: artworkURL),
                   let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func updatePlaybackStateInNowPlaying() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - MPRemoteCommandCenter
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.play()
            }
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.pause()
            }
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.togglePlayPause()
            }
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.onTrackFinished?()
            }
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                // Jika sudah lebih dari 3 detik, restart lagu. Jika belum, ganti ke track sebelumnya
                if self.currentTime > 3.0 {
                    self.seek(to: 0)
                } else {
                    self.onTrackFinished?()
                }
            }
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor in
                self?.seek(to: positionEvent.positionTime)
            }
            return .success
        }
    }
}
