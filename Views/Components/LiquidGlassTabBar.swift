//
//  LiquidGlassTabBar.swift
//  Freetify
//
//  Floating 3D Liquid Glass TabBar (iOS 17+ / 18+ Universal SDK Support)
//  Menggabungkan lensa kaca cembung 3D realistis, gesture usap 1:1, tap elastis, dan haptics.
//

import SwiftUI
import UIKit

public enum LiquidGlassTabBarMetrics {
    public static let contentHeight: CGFloat = 58
    public static let bubbleHeight: CGFloat = 48
    public static let margin: CGFloat = 5
    public static let restingBottomInset: CGFloat = 6
}

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

            // Posisi X lensa cairan kaca: mengikuti sentuhan jari atau diam di tab aktif
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
                // 1. Base Dark Frosted Glass Capsule Track (Lintasan Kaca Gelap Luar)
                Capsule()
                    .fill(Color(hex: "0D1117").opacity(0.88))
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
                    .frame(height: LiquidGlassTabBarMetrics.contentHeight)
                    .shadow(color: Color.black.opacity(0.40), radius: 16, x: 0, y: 8)

                // 2. Visible 3D Crystal Liquid Convex Glass Lens (Lensa Kaca Cembung 3D)
                CrystalConvexGlassLens()
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

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                                .scaleEffect(isSelected ? 1.10 : 1.0)
                                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
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

// MARK: - Sub-komponen Lensa Kaca Cembung 3D (Crystal Convex Glass Lens)
public struct CrystalConvexGlassLens: View {
    public init() {}

    public var body: some View {
        ZStack {
            // 1. Lapisan Kaca Kristal Translucent + Refractive Ambient Core
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.95))
                .overlay {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.30),
                                    Color(hex: "00F2FE").opacity(0.14),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .clipShape(Capsule())
                .shadow(color: Color(hex: "00F2FE").opacity(0.28), radius: 10, y: 3)

            // 2. Specular Top Convex Glare (Pantulan Kilau Kaca Cembung Elips)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.70),
                            Color.white.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(2)

            // 3. Specular Curved Rim Reflection (Pantulan Garis Kaca Lengkung Bawah)
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.85),
                            Color.white.opacity(0.15),
                            Color(hex: "00F2FE").opacity(0.40)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        }
    }
}
