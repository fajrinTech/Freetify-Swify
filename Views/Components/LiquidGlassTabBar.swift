import SwiftUI
import UIKit

/// Floating Liquid Glass Bottom Navigation Bar (SwiftUI)
/// Efek kaca cembung (convex highlight), morphing indicator meleleh dengan matchedGeometryEffect,
/// pegas elastis spring (response: 0.45, dampingFraction: 0.65), dan haptic feedback ringan.
public struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var indicatorNamespace

    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }

    private let tabs = TabItem.allCases

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(hex: "0D1117").opacity(0.88))
                .overlay {
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.35))
                }
                .overlay {
                    // Convex highlight: terang di tepi atas, memudar halus ke bawah
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
        )
        .shadow(color: Color.black.opacity(0.40), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private func tabButton(for tab: TabItem) -> some View {
        let isSelected = (selectedTab == tab)

        Button {
            if selectedTab != tab {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                    selectedTab = tab
                }
            }
        } label: {
            ZStack {
                // Morphing Liquid Glass Active Indicator
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.28),
                                    Color(hex: "00F2FE").opacity(0.12),
                                    Color.white.opacity(0.06)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            // Convex top highlight pada lensa indikator
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.65),
                                            Color(hex: "00F2FE").opacity(0.30),
                                            Color.white.opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .shadow(color: Color(hex: "00F2FE").opacity(0.25), radius: 8, y: 2)
                        .matchedGeometryEffect(id: "activeTabIndicator", in: indicatorNamespace)
                }

                // Konten Tab (Ikon + Label)
                VStack(spacing: 3) {
                    Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                        .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)

                    Text(tab.title)
                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(Rectangle())
            }
            .frame(height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
