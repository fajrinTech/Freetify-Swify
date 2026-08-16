import SwiftUI

/// Floating Ultra Liquid Glass TabBar dengan animasi transisi capsule morphing dan pantulan cahaya dinamis
public struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem
    @Namespace private var glassNamespace

    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(TabItem.allCases) { tab in
                let isSelected = (selectedTab == tab)

                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                            .font(.system(size: isSelected ? 20 : 18, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.48))
                            .shadow(color: isSelected ? Color(hex: "00F2FE").opacity(0.6) : .clear, radius: 8, x: 0, y: 0)

                        Text(tab.title)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.48))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.24), Color.white.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.55), Color(hex: "00F2FE").opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                                .shadow(color: Color(hex: "00F2FE").opacity(0.2), radius: 10, x: 0, y: 0)
                                .matchedGeometryEffect(id: "activeTabIndicator", in: glassNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .frame(height: 62)
        .liquidGlassCapsule(tint: Color(hex: "0B0E14").opacity(0.78))
        .padding(.horizontal, 28)
        .padding(.bottom, 12)
        // Dual-Layer Floating Shadows:
        .shadow(color: Color.black.opacity(0.55), radius: 14, x: 0, y: 7) // Contact Shadow
        .shadow(color: Color(hex: "00F2FE").opacity(0.12), radius: 26, x: 0, y: 12) // Ambient Floating Neon Shadow
    }
}
