import Foundation
import AVFoundation

/// Layanan inti pemutar audio native iOS berbasis standar resmi Apple AVFoundation
@Observable
@MainActor
public final class AudioPlayerService {
    public static let shared = AudioPlayerService()

    private var player: AVPlayer?
    private var timeObserver: Any?

    public var currentTrack: Track?
    public var isPlaying: Bool = false
    public var currentTime: Double = 0.0
    public var duration: Double = 180.0

    public init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("[AudioPlayerService] AudioSession setup error: \(error.localizedDescription)")
        }
    }

    public func loadAndPlay(track: Track) {
        self.currentTrack = track
        self.duration = (track.duration > 0 && !track.duration.isNaN) ? track.duration : 180.0
        self.currentTime = 0.0

        setupAudioSession()

        // Hapus observer lama sebelum membuat item baru
        if let obs = timeObserver, let p = player {
            p.removeTimeObserver(obs)
            timeObserver = nil
        }

        let playerItem = AVPlayerItem(url: track.audioURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        self.player = newPlayer

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        self.timeObserver = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
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

        newPlayer.play()
        self.isPlaying = true
    }

    public func play() {
        setupAudioSession()
        player?.play()
        self.isPlaying = true
    }

    public func pause() {
        player?.pause()
        self.isPlaying = false
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
    }
}
