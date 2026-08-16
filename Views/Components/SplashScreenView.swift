import SwiftUI

/// Layar Splash Pembuka Interaktif Freetify dengan animasi Equalizer Berdenyut & Ambient Glow
public struct SplashScreenView: View {
    @State private var isAnimating: Bool = false
    @State private var wavePhase: Double = 0
    @State private var textOpacity: Double = 0
    @State private var glowScale: CGFloat = 0.8

    public init() {}

    public var body: some View {
        ZStack {
            // Background OLED Dark
            Color(hex: "07090E").ignoresSafeArea()

            // Ambient Glow di Latar Belakang
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "00F2FE").opacity(0.25),
                            Color(hex: "4FACFE").opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .scaleEffect(glowScale)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowScale)

            VStack(spacing: 28) {
                // Logo Gelembung Kaca dengan Equalizer Bernyawa
                ZStack {
                    // Cincin Luar Bersinar
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(hex: "00F2FE").opacity(0.8),
                                    Color(hex: "4FACFE").opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 104, height: 104)
                        .shadow(color: Color(hex: "00F2FE").opacity(0.4), radius: 20, x: 0, y: 0)

                    // Wadah Kaca Gelap
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "151C28").opacity(0.9),
                                    Color(hex: "0B0F17").opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)

                    // 5 Bar Animasi Equalizer Musik
                    HStack(spacing: 5) {
                        ForEach(0..<5) { index in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "00F2FE"), Color(hex: "4FACFE")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 4.5, height: barHeight(for: index))
                                .shadow(color: Color(hex: "00F2FE").opacity(0.6), radius: 4, x: 0, y: 0)
                        }
                    }
                }
                .scaleEffect(isAnimating ? 1.0 : 0.7)
                .opacity(isAnimating ? 1.0 : 0.0)

                // Tipografi Brand FREETIFY & Subtitle
                VStack(spacing: 8) {
                    Text("FREETIFY")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "E2E8F0"), Color(hex: "00F2FE")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "00F2FE").opacity(0.35), radius: 10, x: 0, y: 3)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "00F2FE"))
                            .frame(width: 5, height: 5)
                            .shadow(color: Color(hex: "00F2FE"), radius: 4)

                        Text("Hi-Res Audio Streaming")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "94A3B8"))
                            .tracking(1.5)
                    }
                }
                .opacity(textOpacity)
                .offset(y: textOpacity == 1.0 ? 0 : 10)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.7)) {
                isAnimating = true
                glowScale = 1.15
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                textOpacity = 1.0
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        if !isAnimating { return 8 }
        switch index {
        case 0: return 24
        case 1: return 42
        case 2: return 30
        case 3: return 48
        case 4: return 20
        default: return 26
        }
    }
}
