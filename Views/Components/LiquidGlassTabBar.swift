import SwiftUI

/// Floating 3D Crystal Liquid Glass Bubble TabBar
/// Menggabungkan bentuk kapsul yang pas, efek lensa kaca cembung realistis (Specular Top Glare + Rim Reflection),
/// dan fisika kenyal/jelly (Squash & Stretch Spring Elastic Physics) saat berpindah tab.
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
            let bubbleWidth = tabWidth - 8
            let selectedIndex = tabs.firstIndex(of: selectedTab) ?? 0
            let restingX = (CGFloat(selectedIndex) * tabWidth) + 4

            let bubbleX: CGFloat = {
                if let touchX = dragPositionX {
                    let clamped = max(4, min(touchX - bubbleWidth / 2, totalWidth - bubbleWidth - 4))
                    return clamped
                }
                return restingX
            }()

            ZStack(alignment: .leading) {
                // 1. Base Dark Frosted Glass Capsule Track (Lintasan Kaca Gelap)
                Capsule()
                    .fill(Color(hex: "0D1117").opacity(0.90))
                    .overlay {
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.30))
                    }
                    .overlay {
                        // Hairline Specular Outer Border
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.22),
                                        Color(hex: "00F2FE").opacity(0.12),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .frame(height: 58)
                    .shadow(color: Color.black.opacity(0.50), radius: 16, x: 0, y: 8)

                // 2. Pure 3D Crystal Liquid Glass Jelly Bubble (Kaca Cembung & Fisika Kenyal)
                CrystalConvexGlassBubble()
                    .frame(width: bubbleWidth, height: 50)
                    .offset(x: bubbleX, y: 4)
                    // Efek Kenyal / Jelly Squash & Stretch saat disentuh & digerakkan
                    .scaleEffect(
                        x: isTouching ? 1.18 : 1.0,
                        y: isTouching ? 0.88 : 1.0,
                        anchor: .center
                    )
                    // Animasi Pegas Kenyal Bouncy Jelly (Damping 0.54)
                    .animation(
                        isTouching
                            ? .interactiveSpring(response: 0.12, dampingFraction: 0.85)
                            : .spring(response: 0.36, dampingFraction: 0.54),
                        value: bubbleX
                    )
                    .animation(
                        .spring(response: 0.32, dampingFraction: 0.52),
                        value: isTouching
                    )

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                                .scaleEffect(isSelected ? 1.12 : 1.0)
                                .animation(.spring(response: 0.32, dampingFraction: 0.55), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                        }
                        .frame(width: tabWidth, height: 58)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.36, dampingFraction: 0.54)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
            }
            .frame(height: 58)
            .contentShape(Rectangle())
            .gesture(
                // Usap Jari Real-Time dengan Fisika Jelly Elastis
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

                        withAnimation(.spring(response: 0.36, dampingFraction: 0.54)) {
                            selectedTab = tabs[safeIndex]
                            dragPositionX = nil
                            isTouching = false
                        }
                    }
            )
        }
        .frame(height: 58)
        .padding(.horizontal, 20)
        .padding(.bottom, 2)
    }
}

// MARK: - Sub-komponen Kaca Cembung 3D Realistis (Liquid Convex Glass)
public struct CrystalConvexGlassBubble: View {
    public init() {}

    public var body: some View {
        ZStack {
            // 1. Lapisan Kaca Kristal Translucent + Refractive Ambient Glow
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.24),
                                    Color(hex: "00F2FE").opacity(0.10),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: 36
                            )
                        )
                }
                .clipShape(Capsule())
                .shadow(color: Color(hex: "00F2FE").opacity(0.30), radius: 10, y: 3)

            // 2. Specular Top Convex Glare (Pantulan Kilau Kaca Cembung Atas yang Mengkilap)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.75),
                            Color.white.opacity(0.18),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(2)

            // 3. Specular Bottom Rim Reflection (Pantulan Garis Kaca Lengkung Bawah)
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
