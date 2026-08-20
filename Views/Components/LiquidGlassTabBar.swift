import SwiftUI
import UIKit

/// Floating 3D Liquid Glass Bottom Navigation Bar (SwiftUI)
/// Mendukung DUA mode interaksi:
/// 1. Gesture usap/geser jari real-time 1:1 (Lensa kaca mengikuti jari dan snap ke tab tujuan)
/// 2. Ketuk langsung (Tap) dengan morphing elastis spring (0.45 / 0.65)
/// Lengkap dengan efek kaca cembung (convex highlight), pendaran ambient cyan, dan haptic feedback ringan.
public struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem
    @Environment(\.colorScheme) private var colorScheme

    @State private var dragPositionX: CGFloat? = nil
    @State private var isTouching: Bool = false

    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }

    private let tabs = TabItem.allCases
    private let trackHeight: CGFloat = 56
    private let bubbleHeight: CGFloat = 46
    private let margin: CGFloat = 5

    public var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tabWidth = totalWidth / CGFloat(tabs.count)
            let bubbleWidth = tabWidth - (margin * 2)
            let selectedIndex = tabs.firstIndex(of: selectedTab) ?? 0
            let restingX = (CGFloat(selectedIndex) * tabWidth) + margin

            // Posisi X lensa cairan: mengikuti jari saat diusap, atau di tab aktif saat diam
            let bubbleX: CGFloat = {
                if let touchX = dragPositionX {
                    let rawX = touchX - bubbleWidth / 2
                    let minX = margin
                    let maxX = totalWidth - bubbleWidth - margin
                    return max(minX, min(rawX, maxX))
                }
                return restingX
            }()

            ZStack(alignment: .leading) {
                // 1. Base Dark Frosted Glass Capsule Track (Lintasan Kaca Gelap)
                Capsule()
                    .fill(Color(hex: "0D1117").opacity(0.90))
                    .overlay {
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.35))
                    }
                    .overlay {
                        // Convex Specular Outer Border (Terang di atas, pudar di bawah)
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: colorScheme == .dark
                                        ? [Color.white.opacity(0.32), Color.white.opacity(0.04)]
                                        : [Color.white.opacity(0.75), Color.white.opacity(0.12)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    }
                    .frame(height: trackHeight)
                    .shadow(color: Color.black.opacity(0.42), radius: 16, x: 0, y: 8)

                // 2. Liquid Glass Convex Lens Indicator (Lensa Kaca Cembung 3D)
                ZStack {
                    // Refractive glass body
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.28),
                                    Color(hex: "00F2FE").opacity(0.12),
                                    Color.white.opacity(0.06)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            // Specular Top Convex Glare
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.70),
                                            Color(hex: "00F2FE").opacity(0.30),
                                            Color.white.opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.0
                                )
                        }
                        .shadow(color: Color(hex: "00F2FE").opacity(0.25), radius: 8, y: 2)
                }
                .frame(width: bubbleWidth, height: bubbleHeight)
                .offset(x: bubbleX)
                .scaleEffect(isTouching ? 1.04 : 1.0)
                .animation(
                    isTouching
                        ? .interactiveSpring(response: 0.15, dampingFraction: 0.88)
                        : .spring(response: 0.40, dampingFraction: 0.68),
                    value: bubbleX
                )
                .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isTouching)

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                                .scaleEffect(isSelected ? 1.08 : 1.0)
                                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                        }
                        .frame(width: tabWidth, height: trackHeight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTab != tab {
                                triggerHaptic()
                                withAnimation(.spring(response: 0.40, dampingFraction: 0.68)) {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: trackHeight)
            .contentShape(Rectangle())
            .gesture(
                // Gesture Usap/Geser Jari Real-Time 1:1
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isTouching = true
                        dragPositionX = value.location.x

                        let clampedX = max(0, min(value.location.x, totalWidth - 1))
                        let targetIndex = Int(clampedX / tabWidth)
                        let safeIndex = max(0, min(targetIndex, tabs.count - 1))
                        let targetTab = tabs[safeIndex]

                        if selectedTab != targetTab {
                            triggerHaptic()
                            selectedTab = targetTab
                        }
                    }
                    .onEnded { value in
                        let clampedX = max(0, min(value.location.x, totalWidth - 1))
                        let targetIndex = Int(clampedX / tabWidth)
                        let safeIndex = max(0, min(targetIndex, tabs.count - 1))

                        withAnimation(.spring(response: 0.40, dampingFraction: 0.68)) {
                            selectedTab = tabs[safeIndex]
                            dragPositionX = nil
                            isTouching = false
                        }
                    }
            )
        }
        .frame(height: trackHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
