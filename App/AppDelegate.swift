import UIKit
import AVFoundation

/// AppDelegate untuk konfigurasi background mode audio dan siklus hidup aplikasi iOS
public final class AppDelegate: NSObject, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureAudioSession()
        return true
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch {
            print("[AppDelegate] Gagal mengonfigurasi AVAudioSession background mode: \(error)")
        }
    }
}
