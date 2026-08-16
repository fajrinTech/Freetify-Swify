import Foundation
import AVFoundation
import MediaPlayer
import UIKit

/// Layanan inti pemutar audio native iOS dengan dukungan Background Playback, Lock Screen, dan Remote Controls
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

    // MARK: - Audio Session Setup
    public func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("[AudioPlayerService] AudioSession setup error: \(error.localizedDescription)")
        }
    }

    // MARK: - Playback Controls
    public func loadAndPlay(track: Track) {
        self.currentTrack = track
        self.duration = (track.duration > 0 && !track.duration.isNaN) ? track.duration : 180.0
        self.currentTime = 0

        removeTimeObserver()
        removeItemEndObserver()

        let playbackURL = track.cachedLocalAudioURL ?? track.audioURL
        let playerItem = AVPlayerItem(url: playbackURL)

        if let existingPlayer = player {
            existingPlayer.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
        }

        player?.automaticallyWaitsToMinimizeStalling = true
        setupTimeObserver()
        setupItemEndObserver(for: playerItem)

        play()
        updateNowPlayingInfo(track: track)
    }

    public func play() {
        setupAudioSession()
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
        guard !time.isNaN && !time.isInfinite && time >= 0 else { return }
        let validTime = min(time, max(duration, 0.0))
        let cmTime = CMTime(seconds: validTime, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self = self else { return }
                self.currentTime = validTime
                self.onTimeUpdate?(validTime)
                self.updatePlaybackStateInNowPlaying()
            }
        }
    }

    // MARK: - Periodic Time Observer (Stabilized with 0.25s interval & MainActor.assumeIsolated)
    private func setupTimeObserver() {
        guard let activePlayer = player else { return }
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserverToken = activePlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self = self else { return }
                let seconds = CMTimeGetSeconds(time)
                if !seconds.isNaN && !seconds.isInfinite && seconds >= 0 {
                    self.currentTime = seconds
                    self.onTimeUpdate?(seconds)
                }

                if let item = self.player?.currentItem {
                    let itemDuration = CMTimeGetSeconds(item.duration)
                    if !itemDuration.isNaN && !itemDuration.isInfinite && itemDuration > 0 {
                        self.duration = itemDuration
                        self.onDurationUpdate?(itemDuration)
                    }
                }
            }
        }
    }

    private func removeTimeObserver() {
        if let token = timeObserverToken, let activePlayer = player {
            activePlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    private func setupItemEndObserver(for item: AVPlayerItem) {
        removeItemEndObserver()

        itemEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self = self else { return }
                self.onTrackFinished?()
            }
        }
    }

    private func removeItemEndObserver() {
        if let observer = itemEndObserver {
            NotificationCenter.default.removeObserver(observer)
            itemEndObserver = nil
        }
    }

    // MARK: - MPNowPlayingInfoCenter (Lock Screen & Dynamic Island)
    private func updateNowPlayingInfo(track: Track) {
        let validDuration = (duration > 0 && !duration.isNaN && !duration.isInfinite) ? duration : (track.duration > 0 ? track.duration : 180.0)
        let validCurrentTime = (!currentTime.isNaN && !currentTime.isInfinite && currentTime >= 0) ? currentTime : 0.0

        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyAlbumTitle: track.album,
            MPMediaItemPropertyPlaybackDuration: validDuration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: validCurrentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]

        if let artworkURL = track.artworkURL {
            Task { @MainActor in
                if let (data, _) = try? await URLSession.shared.data(from: artworkURL),
                   let image = UIImage(data: data),
                   image.size.width > 0 && image.size.height > 0 {
                    let targetSize = CGSize(width: min(image.size.width, 300), height: min(image.size.height, 300))
                    let renderer = UIGraphicsImageRenderer(size: targetSize)
                    let resizedImage = renderer.image { _ in
                        image.draw(in: CGRect(origin: .zero, size: targetSize))
                    }
                    let artwork = MPMediaItemArtwork(boundsSize: targetSize) { _ in resizedImage }
                    var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? nowPlayingInfo
                    info[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                }
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func updatePlaybackStateInNowPlaying() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        let validCurrentTime = (!currentTime.isNaN && !currentTime.isInfinite && currentTime >= 0) ? currentTime : 0.0
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = validCurrentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - MPRemoteCommandCenter
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                self?.play()
            }
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                self?.pause()
            }
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                self?.togglePlayPause()
            }
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                self?.onTrackFinished?()
            }
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self = self else { return }
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
            MainActor.assumeIsolated {
                self?.seek(to: positionEvent.positionTime)
            }
            return .success
        }
    }
}
