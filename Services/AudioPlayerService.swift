import Foundation
import AVFoundation

/// Layanan inti pemutar audio native iOS berbasis standar resmi Apple AVFoundation
@Observable
@MainActor
public final class AudioPlayerService {
    public static let shared = AudioPlayerService()

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var itemEndObserver: Any?

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

        // Hapus observer lama sebelum membuat item baru
        if let obs = timeObserver, let p = player {
            p.removeTimeObserver(obs)
            timeObserver = nil
        }
        if let obs = itemEndObserver {
            NotificationCenter.default.removeObserver(obs)
            itemEndObserver = nil
        }

        let playerItem = AVPlayerItem(url: track.audioURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        self.player = newPlayer

        // Interval 0.2s untuk sinkronisasi lirik karaoke yang responsif dan presisi
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

        // Auto-play lagu selanjutnya saat lagu ini selesai
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
