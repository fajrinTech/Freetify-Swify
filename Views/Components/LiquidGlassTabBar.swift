import SwiftUI

/// Floating Minimalist Liquid Glass TabBar (Apple VisionOS / Dynamic Island Dark Glass Pill)
/// Tampilan bersih, elegan, dan proporsional dengan indikator tab aktif yang menyatu halus di dalam kapsul kaca
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
            let indicatorWidth = tabWidth - 8
            let selectedIndex = tabs.firstIndex(of: selectedTab) ?? 0
            let restingX = (CGFloat(selectedIndex) * tabWidth) + 4

            let indicatorX: CGFloat = {
                if let touchX = dragPositionX {
                    let clamped = max(4, min(touchX - indicatorWidth / 2, totalWidth - indicatorWidth - 4))
                    return clamped
                }
                return restingX
            }()

            ZStack(alignment: .leading) {
                // 1. Base Sleek Dark Frosted Glass Capsule (Kapsul Utama Kaca Gelap)
                Capsule()
                    .fill(Color(hex: "0D1117").opacity(0.88))
                    .overlay {
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.35))
                    }
                    .overlay {
                        // Hairline Specular Glass Border
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
                    .shadow(color: Color.black.opacity(0.45), radius: 16, x: 0, y: 8)

                // 2. Active Tab Glass Indicator (Indikator Kaca Menyatu Halus di Dalam Track)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color(hex: "00F2FE").opacity(0.12),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 0.8)
                    }
                    .frame(width: indicatorWidth, height: 48)
                    .offset(x: indicatorX)
                    .scaleEffect(isTouching ? 1.04 : 1.0)
                    .animation(
                        isTouching
                            ? .interactiveSpring(response: 0.15, dampingFraction: 0.86)
                            : .spring(response: 0.32, dampingFraction: 0.72),
                        value: indicatorX
                    )
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isTouching)

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                                .scaleEffect(isSelected ? 1.08 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                        }
                        .frame(width: tabWidth, height: 56)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
            }
            .frame(height: 56)
            .contentShape(Rectangle())
            .gesture(
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

                        withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                            selectedTab = tabs[safeIndex]
                            dragPositionX = nil
                            isTouching = false
                        }
                    }
            )
        }
        .frame(height: 56)
        .padding(.horizontal, 24)
        .padding(.bottom, 2)
    }
}
