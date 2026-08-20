//
//  LiquidGlassTabBar.swift
//  Freetify
//
//  1-to-1 Visual and Interaction Recreation of UnionTabView (https://github.com/unionst/union-tab-view)
//  Menghadirkan lensa kaca transparan berdaya bias optik tinggi (chromatic refraction rim + dark optical shadow).
//

import SwiftUI
import UIKit

public enum LiquidGlassTabBarMetrics {
    public static let contentHeight: CGFloat = 58
    public static let bubbleHeight: CGFloat = 48
    public static let margin: CGFloat = 5
    public static let restingBottomInset: CGFloat = 6
}

/// Floating Liquid Glass Tab Bar (SwiftUI Native)
public struct LiquidGlassTabBar: View {
    @Binding public var selectedTab: TabItem
    @Environment(\.colorScheme) private var colorScheme
    public var onReselect: ((TabItem) -> Void)? = nil

    @State private var dragPositionX: CGFloat? = nil
    @State private var isTouching: Bool = false

    public init(
        selectedTab: Binding<TabItem>,
        onReselect: ((TabItem) -> Void)? = nil
    ) {
        self._selectedTab = selectedTab
        self.onReselect = onReselect
    }

    private let tabs = TabItem.allCases

    public var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tabWidth = totalWidth / CGFloat(tabs.count)
            let bubbleWidth = tabWidth - (LiquidGlassTabBarMetrics.margin * 2)
            let selectedIndex = tabs.firstIndex(of: selectedTab) ?? 0
            let restingX = (CGFloat(selectedIndex) * tabWidth) + LiquidGlassTabBarMetrics.margin

            // Posisi X lensa kaca cair: mengikuti sentuhan jari atau diam di tab aktif
            let bubbleX: CGFloat = {
                if let touchX = dragPositionX {
                    let rawX = touchX - bubbleWidth / 2
                    let minX = LiquidGlassTabBarMetrics.margin
                    let maxX = totalWidth - bubbleWidth - LiquidGlassTabBarMetrics.margin
                    return max(minX, min(rawX, maxX))
                }
                return restingX
            }()

            ZStack(alignment: .leading) {
                // 1. Lintasan Kaca Gelap Transparan Luar (Outer Translucent Glass Track)
                Capsule()
                    .fill(Color(hex: "0D1117").opacity(0.85))
                    .overlay {
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.35))
                    }
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.22),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.8
                            )
                    }
                    .frame(height: LiquidGlassTabBarMetrics.contentHeight)
                    .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 7)

                // 2. Lensa Kaca Liquid Refraktif 1-to-1 Persis Union (Union Liquid Glass Lens)
                UnionLiquidGlassLens()
                    .frame(width: bubbleWidth, height: LiquidGlassTabBarMetrics.bubbleHeight)
                    .offset(x: bubbleX)
                    .scaleEffect(
                        x: isTouching ? 1.05 : 1.0,
                        y: isTouching ? 0.96 : 1.0,
                        anchor: .center
                    )
                    .animation(
                        isTouching
                            ? .interactiveSpring(response: 0.15, dampingFraction: 0.88)
                            : .spring(response: 0.38, dampingFraction: 0.65),
                        value: bubbleX
                    )
                    .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isTouching)

                // 3. Tab Items (Ikon & Label Teks)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                .symbolEffect(.bounce, value: isSelected)
                                .foregroundColor(isSelected ? Color(hex: "00F2FE") : Color.white.opacity(0.45))
                                .scaleEffect(isSelected ? 1.10 : 1.0)
                                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color(hex: "00F2FE") : Color.white.opacity(0.45))
                        }
                        .frame(width: tabWidth, height: LiquidGlassTabBarMetrics.contentHeight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTab != tab {
                                triggerHaptic()
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
                                    selectedTab = tab
                                }
                            } else {
                                triggerHaptic()
                                onReselect?(tab)
                            }
                        }
                    }
                }
            }
            .frame(height: LiquidGlassTabBarMetrics.contentHeight)
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

                        withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
                            selectedTab = tabs[safeIndex]
                            dragPositionX = nil
                            isTouching = false
                        }
                    }
            )
        }
        .frame(height: LiquidGlassTabBarMetrics.contentHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, LiquidGlassTabBarMetrics.restingBottomInset)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Lensa Kaca Liquid Refraktif Persis Union (Union Liquid Glass Lens)
public struct UnionLiquidGlassLens: View {
    public init() {}

    public var body: some View {
        ZStack {
            // 1. Badan Kaca Transparan Halus (.ultraThinMaterial + Ambient Refraction)
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.95))
                .overlay {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.20),
                                    Color(hex: "00F2FE").opacity(0.12),
                                    Color.white.opacity(0.06)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .clipShape(Capsule())

            // 2. Bayangan Refraksi Optik Atas & Bawah (Dark Optical Depth Rims persis SS 3)
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.42),
                            Color.clear,
                            Color.black.opacity(0.48)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2.5
                )

            // 3. Garis Pembias Kristal & Refraksi Kromatik (Specular & Chromatic Rim)
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.75),
                            Color(hex: "00F2FE").opacity(0.40),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
        }
        // Pendaran cahaya aksen halus di bawah lensa
        .shadow(color: Color(hex: "00F2FE").opacity(0.22), radius: 8, y: 2)
    }
}
