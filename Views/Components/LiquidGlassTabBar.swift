import SwiftUI

/// Floating Liquid Glass TabBar dengan animasi transisi capsule morphing
public struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem
    @Namespace private var glassNamespace

    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.activeIcon : tab.icon)
                            .font(.system(size: 19, weight: .semibold))
                        Text(tab.title)
                            .font(.system(size: 11, weight: selectedTab == tab ? .bold : .medium))
                    }
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: 52)
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                                .matchedGeometryEffect(id: "activeTabIndicator", in: glassNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 60)
        .liquidGlassCapsule(tint: Color(hex: "12161C").opacity(0.85))
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
    }
}
