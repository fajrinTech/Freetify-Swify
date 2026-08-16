import Foundation
import AVFoundation

/// Layanan inti pemutar audio native iOS berbasis standar resmi Apple AVFoundation dengan transisi Fade-In halus
@Observable
@MainActor
public final class AudioPlayerService {
    public static let shared = AudioPlayerService()

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var itemEndObserver: Any?
    private var fadeTask: Task<Void, Never>?

    public var currentTrack: Track?
    public var isPlaying: Bool = false
    public var currentTime: Double = 0.0
    public var duration: Double = 180.0
    public var onTrackFinished: (() -> Void)?

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

        // Hapus observer item lama
        if let obs = itemEndObserver {
            NotificationCenter.default.removeObserver(obs)
            itemEndObserver = nil
        }

        let playerItem = AVPlayerItem(url: track.audioURL)
        playerItem.preferredForwardBufferDuration = 10.0

        if let existingPlayer = player {
            existingPlayer.replaceCurrentItem(with: playerItem)
            existingPlayer.automaticallyWaitsToMinimizeStalling = false
        } else {
            let newPlayer = AVPlayer(playerItem: playerItem)
            newPlayer.automaticallyWaitsToMinimizeStalling = false
            self.player = newPlayer

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
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self = self else { return }
                self.onTrackFinished?()
            }
        }

        // Putar audio dengan transisi Fade-In yang lembut dan elegan
        fadeInAudio(duration: 0.35)
        self.isPlaying = true
    }

    public func play() {
        setupAudioSession()
        fadeInAudio(duration: 0.25)
        self.isPlaying = true
    }

    public func pause() {
        fadeTask?.cancel()
        fadeTask = nil
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

    // MARK: - Smooth Audio Fade-In Swell
    private func fadeInAudio(duration: TimeInterval) {
        fadeTask?.cancel()
        fadeTask = nil

        guard let activePlayer = player else { return }
        activePlayer.volume = 0.0
        activePlayer.play()

        fadeTask = Task { @MainActor [weak self, weak activePlayer] in
            guard let _ = self, let p = activePlayer else { return }
            let totalSteps = 15
            let intervalNanos = UInt64((duration / Double(totalSteps)) * 1_000_000_000)

            for step in 1...totalSteps {
                if Task.isCancelled { break }
                try? await Task.sleep(nanoseconds: intervalNanos)
                if Task.isCancelled { break }
                p.volume = min(1.0, Float(step) / Float(totalSteps))
            }
            p.volume = 1.0
        }
    }
}
