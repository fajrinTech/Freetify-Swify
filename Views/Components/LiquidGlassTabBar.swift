import SwiftUI

/// Floating 3D Chromatic Liquid Glass Bubble TabBar (Gaya Telegram iOS Floating Orb)
/// Dilengkapi gelembung kaca cair cembung 3D, cincin dispersi kromatik pelangi, dan gesture usap / drag interaktif
public struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem

    @GestureState private var dragTranslation: CGFloat = 0
    @State private var isDragging: Bool = false

    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }

    private let tabs = TabItem.allCases

    public var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tabWidth = totalWidth / CGFloat(tabs.count)
            let selectedIndex = tabs.firstIndex(of: selectedTab) ?? 0

            ZStack(alignment: .leading) {
                // 1. Dark Frosted Glass Base Track (Kapsul Lintasan Gelap)
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(Color(hex: "0D1117").opacity(0.85))
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
                    .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 8)

                // 2. 3D Chromatic Liquid Glass Bubble (Gelembung Kaca Melayang seperti di Screenshot)
                let bubbleWidth = tabWidth * 0.94
                let bubbleX = (CGFloat(selectedIndex) * tabWidth) + (tabWidth - bubbleWidth) / 2

                chromaticLiquidBubble(width: bubbleWidth, height: 66)
                    .offset(x: bubbleX)
                    .animation(.spring(response: 0.34, dampingFraction: 0.72), value: selectedTab)

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        Button {
                            withAnimation(.spring(response: 0.34, dampingFraction: 0.72)) {
                                selectedTab = tab
                            }
                        } label: {
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
                                    .scaleEffect(isSelected ? 1.14 : 1.0)
                                    .shadow(color: isSelected ? Color(hex: "00F2FE").opacity(0.7) : .clear, radius: 10, x: 0, y: 0)

                                Text(tab.title)
                                    .font(.system(size: 11, weight: isSelected ? .heavy : .semibold))
                                    .foregroundColor(isSelected ? .white : .white.opacity(0.48))
                                    .shadow(color: isSelected ? Color.black.opacity(0.4) : .clear, radius: 2, x: 0, y: 1)
                            }
                            .frame(width: tabWidth, height: 60)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: 60)
            .contentShape(Rectangle())
            .gesture(
                // Gesture Usap / Drag di Sepanjang Tab Bar secara Real-Time
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let clampedX = max(0, min(value.location.x, totalWidth - 1))
                        let targetIndex = Int(clampedX / tabWidth)
                        let safeIndex = max(0, min(targetIndex, tabs.count - 1))
                        let targetTab = tabs[safeIndex]
                        if selectedTab != targetTab {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.74)) {
                                selectedTab = targetTab
                            }
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
        .frame(height: 66)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    // MARK: - 3D Chromatic Liquid Glass Bubble Orb
    @ViewBuilder
    private func chromaticLiquidBubble(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // 1. Holographic Rainbow Chromatic Dispersion Ring (Cincin Pelangi Pembiasan Cahaya Kaca)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "00F2FE"),
                            Color(hex: "4FACFE"),
                            Color(hex: "7F00FF"),
                            Color(hex: "FF0844"),
                            Color(hex: "FFB199"),
                            Color(hex: "00F2FE")
                        ]),
                        center: .center
                    ),
                    lineWidth: 2.2
                )
                .blur(radius: 1.2)
                .opacity(0.88)

            // 2. Optical Glass Convex Lens Body
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color(hex: "00F2FE").opacity(0.06),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

            // 3. Specular 3D Top-Light Reflection Sheen (Kilau Pantulan Cahaya Atas)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.12),
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
                            Color.white.opacity(0.85),
                            Color(hex: "00F2FE").opacity(0.4),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .frame(width: width, height: height)
        // Dual-Layer 3D Floating & Neon Aura Shadows
        .shadow(color: Color(hex: "00F2FE").opacity(0.45), radius: 14, x: 0, y: 0)
        .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 5)
    }
}
