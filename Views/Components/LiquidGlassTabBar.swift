import SwiftUI

/// Floating 3D Crystal Liquid Glass Bubble TabBar (Pure Monochromatic Glass + Elastic Jelly Spring Physics)
/// Bebas dari warna RGB, 100% Kaca Kristal Bening dengan efek Kenyal/Jelly saat bergeser dan berpindah
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
            let bubbleWidth = tabWidth * 0.92
            let selectedIndex = tabs.firstIndex(of: selectedTab) ?? 0
            let restingX = (CGFloat(selectedIndex) * tabWidth) + (tabWidth - bubbleWidth) / 2

            // Posisi X lensa kaca mengikuti jari saat diusap, atau berada di tab aktif saat diam
            let bubbleX: CGFloat = {
                if let touchX = dragPositionX {
                    let clamped = max(0, min(touchX - bubbleWidth / 2, totalWidth - bubbleWidth))
                    return clamped
                }
                return restingX
            }()

            ZStack(alignment: .leading) {
                // 1. Base Dark Frosted Glass Track (Kapsul Lintasan Gelap)
                Capsule()
                    .fill(Color(hex: "0C0F16").opacity(0.92))
                    .overlay {
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.25))
                    }
                    .overlay {
                        // Hairline Specular Border Kaca Luar
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .frame(height: 64)
                    .shadow(color: Color.black.opacity(0.55), radius: 14, x: 0, y: 7)

                // 2. Pure Crystal Liquid Glass Jelly Bubble (Kenyal / Bouncy Elastic Squash & Stretch)
                CrystalLiquidJellyBubble()
                    .frame(width: bubbleWidth, height: 72)
                    .offset(x: bubbleX, y: -4)
                    // Efek kenyal (Squash & Stretch) saat ditarik/digerakkan
                    .scaleEffect(
                        x: isTouching ? 1.18 : 1.0,
                        y: isTouching ? 0.88 : 1.0,
                        anchor: .center
                    )
                    // Animasi Pegas Kenyal / Bouncy Jelly Elastic (Damping 0.52)
                    .animation(
                        isTouching
                            ? .interactiveSpring(response: 0.12, dampingFraction: 0.85)
                            : .spring(response: 0.38, dampingFraction: 0.52),
                        value: bubbleX
                    )
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.50),
                        value: isTouching
                    )

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: 21, weight: .bold))
                                .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.45))
                                .scaleEffect(isSelected ? 1.16 : 1.0)
                                .animation(.spring(response: 0.32, dampingFraction: 0.55), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                        }
                        .frame(width: tabWidth, height: 64)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.52)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
            }
            .frame(height: 64)
            .contentShape(Rectangle())
            .gesture(
                // Gesture Usap Jari Real-Time 1:1 Tanpa Getaran
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
                        }
                    }
                    .onEnded { value in
                        let clampedX = max(0, min(value.location.x, totalWidth - 1))
                        let targetIndex = Int(clampedX / tabWidth)
                        let safeIndex = max(0, min(targetIndex, tabs.count - 1))

                        withAnimation(.spring(response: 0.38, dampingFraction: 0.52)) {
                            selectedTab = tabs[safeIndex]
                            dragPositionX = nil
                            isTouching = false
                        }
                    }
            )
        }
        .frame(height: 72)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

// MARK: - Sub-komponen Kaca Kristal Murni (100% Bebas RGB, Murni Glass & Refleksi Cahaya)
public struct CrystalLiquidJellyBubble: View {
    public init() {}

    public var body: some View {
        ZStack {
            // 1. Crystal Glass Body (Ultra Thin Translucent Material)
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.22),
                                    Color.white.opacity(0.04),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 40
                            )
                        )
                }
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.40), radius: 10, y: 5)

            // 2. Specular Top Glare (Pantulan Kilau Lensa Kaca Cembung Atas)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.70),
                            Color.white.opacity(0.12),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(2)

            // 3. Specular Bottom Rim Reflection (Pantulan Cahaya Bawah Kaca)
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.85),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        }
    }
}
