import SwiftUI
import UIKit

/// Floating 3D Chromatic Liquid Glass Bubble TabBar (Gaya Telegram iOS Floating Orb - Gambar 2)
/// Dilengkapi pelacakan jari real-time 1:1, efek lensa kaca cair cembung tembus pandang, dan cincin dispersi pelangi kromatik
public struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem

    @State private var dragPositionX: CGFloat? = nil
    @State private var isTouching: Bool = false

    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }

    private let tabs = TabItem.allCases

    public var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tabWidth = totalWidth / CGFloat(tabs.count)
            let bubbleWidth = tabWidth * 0.94
            let selectedIndex = tabs.firstIndex(of: selectedTab) ?? 0
            let restingX = (CGFloat(selectedIndex) * tabWidth) + (tabWidth - bubbleWidth) / 2

            // Posisi X gelembung mengikuti jari 1:1 saat di-drag, atau kembali ke tab aktif saat dilepas
            let bubbleX: CGFloat = {
                if let touchX = dragPositionX {
                    let clamped = max(0, min(touchX - bubbleWidth / 2, totalWidth - bubbleWidth))
                    return clamped
                }
                return restingX
            }()

            ZStack(alignment: .leading) {
                // 1. Dark Frosted Glass Base Track (Kapsul Lintasan Gelap)
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(Color(hex: "0B0E14").opacity(0.88))
                    }
                    .overlay {
                        // Hairline Specular Border
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .frame(height: 60)
                    .shadow(color: Color.black.opacity(0.55), radius: 16, x: 0, y: 8)

                // 2. 3D Chromatic Liquid Glass Bubble (Gelembung Kaca Cair Mengikuti Jari 1:1)
                chromaticLiquidBubble(width: bubbleWidth, height: 66)
                    .offset(x: bubbleX)
                    .scaleEffect(isTouching ? 1.05 : 1.0, anchor: .center)
                    .animation(isTouching ? .interactiveSpring(response: 0.15, dampingFraction: 0.86) : .spring(response: 0.32, dampingFraction: 0.74), value: bubbleX)

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: isSelected ? 21 : 18, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(
                                    isSelected
                                        ? LinearGradient(
                                            colors: [Color(hex: "00F2FE"), Color(hex: "4FACFE")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        : LinearGradient(
                                            colors: [Color.white.opacity(0.48), Color.white.opacity(0.48)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                                .scaleEffect(isSelected ? 1.12 : 1.0)
                                .animation(.spring(response: 0.28, dampingFraction: 0.75), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .heavy : .semibold))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.48))
                        }
                        .frame(width: tabWidth, height: 60)
                    }
                }
            }
            .frame(height: 60)
            .contentShape(Rectangle())
            .gesture(
                // Gesture Drag & Usap Jari Real-Time 1:1
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isTouching = true
                        dragPositionX = value.location.x

                        let clampedX = max(0, min(value.location.x, totalWidth - 1))
                        let targetIndex = Int(clampedX / tabWidth)
                        let safeIndex = max(0, min(targetIndex, tabs.count - 1))
                        let targetTab = tabs[safeIndex]

                        if selectedTab != targetTab {
                            selectedTab = targetTab
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    .onEnded { value in
                        let clampedX = max(0, min(value.location.x, totalWidth - 1))
                        let targetIndex = Int(clampedX / tabWidth)
                        let safeIndex = max(0, min(targetIndex, tabs.count - 1))

                        withAnimation(.spring(response: 0.32, dampingFraction: 0.74)) {
                            selectedTab = tabs[safeIndex]
                            dragPositionX = nil
                            isTouching = false
                        }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            )
        }
        .frame(height: 66)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    // MARK: - 3D Chromatic Liquid Glass Bubble Orb (Persis Gambar 2 Telegram iOS)
    @ViewBuilder
    private func chromaticLiquidBubble(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // 1. Holographic Rainbow Chromatic Dispersion Ring (Cincin Prisma Pelangi Kaca Halus)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "00F2FE"),
                            Color(hex: "4FACFE"),
                            Color(hex: "8A2387"),
                            Color(hex: "E94057"),
                            Color(hex: "F27121"),
                            Color(hex: "FFDD00"),
                            Color(hex: "00F2FE")
                        ]),
                        center: .center
                    ),
                    lineWidth: 2.0
                )
                .blur(radius: 1.0)
                .opacity(0.85)

            // 2. Optical Clear Translucent Glass Lens (Kaca Bening Tembus Pandang)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                }

            // 3. Specular 3D Top Lens Glare (Kilau Pantulan Lensa Atas Khas Apple)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            Color.white.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(2)

            // 4. Subtle Outer Specular Edge
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.80),
                            Color.white.opacity(0.20),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .frame(width: width, height: height)
        // Natural Depth Glass Shadow (Bebas dari warna biru mentereng di luar)
        .shadow(color: Color.black.opacity(0.40), radius: 10, x: 0, y: 5)
    }
}
