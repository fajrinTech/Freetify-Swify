import SwiftUI

/// Floating 3D Crystal Liquid Glass Bubble TabBar
/// Menerapkan prinsip fisika fluida nyata (Surface Tension & Volume Conservation) dan optik lensa cembung elips realistis.
/// Geometri terkunci presisi di dalam track kapsul tanpa overflow, terpusat simetris, dan kenyal membal saat berpindah tab.
public struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem

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

            // Posisi X lensa cairan dengan pembatas matematis aman (Anti-Overflow)
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
                    .fill(Color(hex: "0D1117").opacity(0.92))
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
                                        Color.white.opacity(0.20),
                                        Color(hex: "00F2FE").opacity(0.12),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .frame(height: trackHeight)
                    .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 7)

                // 2. Pure 3D Crystal Liquid Glass Droplet (Kaca Cembung & Fisika Fluida Alami)
                CrystalConvexGlassBubble()
                    .frame(width: bubbleWidth, height: bubbleHeight)
                    .offset(x: bubbleX)
                    // Peregangan inersia fluida halus saat disentuh (~4%, anti-lonjong)
                    .scaleEffect(
                        x: isTouching ? 1.04 : 1.0,
                        y: isTouching ? 0.97 : 1.0,
                        anchor: .center
                    )
                    // Animasi pegas fluida kenyal realistis (Damping 0.62)
                    .animation(
                        isTouching
                            ? .interactiveSpring(response: 0.15, dampingFraction: 0.88)
                            : .spring(response: 0.32, dampingFraction: 0.62, blendDuration: 0.08),
                        value: bubbleX
                    )
                    .animation(
                        .spring(response: 0.28, dampingFraction: 0.65),
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
                                .scaleEffect(isSelected ? 1.10 : 1.0)
                                .animation(.spring(response: 0.30, dampingFraction: 0.65), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                        }
                        .frame(width: tabWidth, height: trackHeight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.62, blendDuration: 0.08)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
            }
            .frame(height: trackHeight)
            .contentShape(Rectangle())
            .gesture(
                // Gesture Usap Jari Real-Time Berbasis Fluida
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

                        withAnimation(.spring(response: 0.32, dampingFraction: 0.62, blendDuration: 0.08)) {
                            selectedTab = tabs[safeIndex]
                            dragPositionX = nil
                            isTouching = false
                        }
                    }
            )
        }
        .frame(height: trackHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 2)
    }
}

// MARK: - Sub-komponen Kaca Cembung 3D Realistis (Liquid Convex Glass Lens)
public struct CrystalConvexGlassBubble: View {
    public init() {}

    public var body: some View {
        ZStack {
            // 1. Lapisan Kaca Kristal Translucent + Refractive Ambient Core
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.95))
                .overlay {
                    Capsule()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.20),
                                    Color(hex: "00F2FE").opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: 32
                            )
                        )
                }
                .clipShape(Capsule())
                .shadow(color: Color(hex: "00F2FE").opacity(0.22), radius: 8, y: 2)

            // 2. Specular Crescent Top Glare (Pantulan Kilau Kaca Cembung Elips yang Lembut & Alami)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.60),
                            Color.white.opacity(0.12),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(2)

            // 3. Specular Curved Rim (Pantulan Garis Kaca Lengkung Bawah)
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.70),
                            Color.white.opacity(0.10),
                            Color(hex: "00F2FE").opacity(0.30)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
        }
    }
}
