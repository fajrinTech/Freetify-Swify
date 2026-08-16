import SwiftUI

/// Floating 3D Chromatic Liquid Glass Bubble TabBar (Formula Lengkap Telegram iOS)
/// Menggunakan Refraksi Kaca Cembung Radial, Cincin Prisma Spektrum (Screen Blend), dan Animasi Pegas Elastis
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

            // Posisi X lensa kaca mengikuti jari saat diusap, atau berada di tab aktif saat diam
            let bubbleX: CGFloat = {
                if let touchX = dragPositionX {
                    let clamped = max(0, min(touchX - bubbleWidth / 2, totalWidth - bubbleWidth))
                    return clamped
                }
                return restingX
            }()

            ZStack(alignment: .leading) {
                // 1. Base Dark Frosted Glass Pill (Lintasan Kapsul Gelap)
                Capsule()
                    .fill(Color(white: 0.10).opacity(0.88))
                    .overlay {
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.3))
                    }
                    .overlay {
                        // Hairline Specular Border
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.30), Color.white.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .frame(height: 64)
                    .shadow(color: Color.black.opacity(0.50), radius: 14, x: 0, y: 7)

                // 2. Liquid Glass Bubble (Indikator Kaca Cembung 72pt Menjulang Mengikuti Tab)
                LiquidBubbleView()
                    .frame(width: bubbleWidth, height: 72)
                    .offset(x: bubbleX, y: -4)
                    .animation(isTouching ? .interactiveSpring(response: 0.15, dampingFraction: 0.88) : .spring(response: 0.45, dampingFraction: 0.65), value: bubbleX)

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: 21, weight: .bold))
                                .foregroundStyle(isSelected ? Color(hex: "00F2FE") : Color.white.opacity(0.50))
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                                .animation(.spring(response: 0.30), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color(hex: "00F2FE") : Color.white.opacity(0.50))
                        }
                        .frame(width: tabWidth, height: 64)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
            }
            .frame(height: 64)
            .contentShape(Rectangle())
            .gesture(
                // Gesture Usap Jari Real-Time 1:1 (Tanpa Getaran Haptic)
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

                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
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

// MARK: - Sub-komponen Kaca Cembung & Chromatic Ring (Formula Telegram)
public struct LiquidBubbleView: View {
    public init() {}

    public var body: some View {
        ZStack {
            // 1. Refraksi Kaca Cembung (Radial Gradient + UltraThinMaterial Jernih)
            Capsule()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    )
                )
                .background(.ultraThinMaterial.opacity(0.35))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.45), radius: 10, y: 5)

            // 2. Chromatic Spectral Edge (Cincin Spektrum Prisma Warna Menyala)
            Capsule()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            Color(red: 0.0, green: 0.9, blue: 1.0), // Cyan
                            Color(red: 0.3, green: 0.2, blue: 1.0), // Deep Blue
                            Color(red: 1.0, green: 0.1, blue: 0.6), // Magenta
                            Color(red: 0.8, green: 1.0, blue: 0.2), // Lime/Yellow
                            Color(red: 0.0, green: 0.9, blue: 1.0)  // Loop ke Cyan
                        ],
                        center: .center
                    ),
                    lineWidth: 2.0
                )
                .blendMode(.screen)

            // 3. Specular Top Glare (Pantulan Kilau Kaca Atas)
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.90),
                            Color.white.opacity(0.20),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    ),
                    lineWidth: 1.2
                )
        }
    }
}
