import Foundation
import AVFoundation
import UIKit
import MediaPlayer

/// Layanan inti pemutar audio native iOS berbasis standar resmi Apple AVFoundation & MediaPlayer
@Observable
@MainActor
public final class AudioPlayerService {
    public static let shared = AudioPlayerService()

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var itemEndObserver: Any?
    private var bgTaskID: UIBackgroundTaskIdentifier = .invalid
    private var currentArtwork: UIImage? = nil
    private var lastNowPlayingRefreshTime: TimeInterval = 0.0
    private var remoteCommandsRegistered = false

    public var currentTrack: Track?
    public var isPlaying: Bool = false
    public var currentTime: Double = 0.0
    public var duration: Double = 180.0
    public var onTrackFinished: (() -> Void)?
    public var onRemoteNext: (() -> Void)?
    public var onRemotePrevious: (() -> Void)?

    // ponytail: init kosong, semua setup dilakukan lazy saat lagu pertama diputar
    public init() {}

    private func ensureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("[AudioPlayerService] AudioSession setup error: \(error.localizedDescription)")
        }
    }

    // MARK: - Lock Screen & Control Center Remote Commands (lazy, dipanggil sekali saat lagu pertama diputar)
    private func ensureRemoteCommandCenter() {
        guard !remoteCommandsRegistered else { return }
        remoteCommandsRegistered = true

        let cc = MPRemoteCommandCenter.shared()

        cc.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.play() }
            return .success
        }
        cc.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
        cc.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.togglePlayPause() }
            return .success
        }
        cc.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.onRemoteNext?() }
            return .success
        }
        cc.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.onRemotePrevious?() }
            return .success
        }
        cc.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let posEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            Task { @MainActor in self?.seek(to: posEvent.positionTime) }
            return .success
        }
    }

    public func updateNowPlayingInfo(artworkImage: UIImage? = nil) {
        guard let track = currentTrack else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        if let img = artworkImage {
            self.currentArtwork = img
        }

        let safeDuration = (duration.isFinite && duration > 0) ? duration : 180.0
        let safeCurrentTime = (currentTime.isFinite && currentTime >= 0) ? currentTime : 0.0

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyAlbumTitle: track.album,
            MPMediaItemPropertyPlaybackDuration: safeDuration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: safeCurrentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let img = currentArtwork, img.cgImage != nil, img.size.width > 0, img.size.height > 0 {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    public func loadAndPlay(track: Track) {
        self.currentTrack = track
        self.duration = (track.duration > 0 && !track.duration.isNaN) ? track.duration : 180.0
        self.currentTime = 0.0
        self.currentArtwork = nil
        self.lastNowPlayingRefreshTime = 0.0

        ensureAudioSession()
        ensureRemoteCommandCenter()

        // Hapus observer item lama
        if let obs = itemEndObserver {
            NotificationCenter.default.removeObserver(obs)
            itemEndObserver = nil
        }

        // Gunakan file lokal disk jika sudah tervalidasi utuh (> 100 KB), atau stream dari cloud
        let playbackURL = LocalCacheService.shared.getLocalAudioURL(trackID: track.id) ?? track.audioURL
        let playerItem = AVPlayerItem(url: playbackURL)
        playerItem.preferredForwardBufferDuration = 5.0

        // Jika memutar via stream cloud, unduh di background secara aman
        if playbackURL == track.audioURL {
            Task {
                await LocalCacheService.shared.cacheAudioFile(trackID: track.id, from: track.audioURL)
            }
        }

        if let existingPlayer = player {
            existingPlayer.replaceCurrentItem(with: playerItem)
            existingPlayer.volume = 1.0
            existingPlayer.play()
        } else {
            let newPlayer = AVPlayer(playerItem: playerItem)
            newPlayer.volume = 1.0
            self.player = newPlayer
            newPlayer.play()

            // Observer waktu diatur satu kali untuk instance player
            let interval = CMTime(seconds: 0.2, preferredTimescale: 600)
            self.timeObserver = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                MainActor.assumeIsolated {
                    guard let self = self else { return }
                    let sec = CMTimeGetSeconds(time)
                    if sec.isFinite && sec >= 0 {
                        self.currentTime = sec
                    }
                    if let item = self.player?.currentItem {
                        let d = CMTimeGetSeconds(item.duration)
                        if d.isFinite && d > 0 {
                            self.duration = d
                        }
                    }
                }
            }
        }

        // Auto-play lagu selanjutnya saat lagu selesai
        self.itemEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: nil
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.startBackgroundTask()
                self.onTrackFinished?()
            }
        }

        self.isPlaying = true
        updateNowPlayingInfo()

        // Unduh cover album untuk Lock Screen
        if let artworkURL = track.artworkURL {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: artworkURL)
                    if let img = UIImage(data: data) {
                        self.updateNowPlayingInfo(artworkImage: img)
                    }
                } catch {
                    // ponytail: artwork gagal = tidak masalah, lagu tetap jalan
                }
            }
        }

        // Selesaikan background task setelah pemutaran lagu baru berjalan
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self.endBackgroundTask()
        }
    }

    public func play() {
        ensureAudioSession()
        player?.volume = 1.0
        player?.play()
        self.isPlaying = true
        updateNowPlayingInfo()
    }

    public func pause() {
        player?.pause()
        self.isPlaying = false
        updateNowPlayingInfo()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    public func seek(to seconds: Double) {
        guard seconds.isFinite && seconds >= 0 else { return }
        self.currentTime = seconds
        let cmTime = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        updateNowPlayingInfo()
    }

    // MARK: - Background Task Management
    private func startBackgroundTask() {
        endBackgroundTask()
        bgTaskID = UIApplication.shared.beginBackgroundTask(withName: "FreetifyAdvanceTrack") { [weak self] in
            Task { @MainActor in
                self?.endBackgroundTask()
            }
        }
    }

    private func endBackgroundTask() {
        if bgTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(bgTaskID)
            bgTaskID = .invalid
        }
    }
}
