//
//  LiquidGlassTabBar.swift
//  Freetify
//
//  Direct implementation of UnionTabView (https://github.com/unionst/union-tab-view)
//

import SwiftUI
import UIKit

/// Mesin penggerak seleksi dan geser native UISegmentedControl dari UnionTabView
@MainActor
public struct SegmentedControlTabBar: UIViewRepresentable {
    public var size: CGSize
    public var barTint: Color
    @Binding public var activeTab: TabItem

    public init(size: CGSize, barTint: Color = .white.opacity(0.22), activeTab: Binding<TabItem>) {
        self.size = size
        self.barTint = barTint
        self._activeTab = activeTab
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIView(context: Context) -> UISegmentedControl {
        let items = TabItem.allCases.compactMap { _ in "" }
        let control = UISegmentedControl(items: items)
        let allCases = Array(TabItem.allCases)
        control.selectedSegmentIndex = allCases.firstIndex(of: activeTab) ?? 0

        // Sembunyikan garis pemisah default, pertahankan indikator seleksi aktif (subviews.last)
        DispatchQueue.main.async {
            for subview in control.subviews {
                if subview is UIImageView && subview != control.subviews.last {
                    subview.alpha = 0
                }
            }
        }

        control.selectedSegmentTintColor = UIColor(barTint)
        control.backgroundColor = .clear

        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.tabSelected(_:)),
            for: .valueChanged
        )
        return control
    }

    public func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        let allCases = Array(TabItem.allCases)
        let targetIndex = allCases.firstIndex(of: activeTab) ?? 0
        if uiView.selectedSegmentIndex != targetIndex {
            uiView.selectedSegmentIndex = targetIndex
        }
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        return size
    }

    public class Coordinator: NSObject {
        var parent: SegmentedControlTabBar

        init(parent: SegmentedControlTabBar) {
            self.parent = parent
        }

        @MainActor @objc func tabSelected(_ control: UISegmentedControl) {
            let allCases = Array(TabItem.allCases)
            if control.selectedSegmentIndex < allCases.count {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                parent.activeTab = allCases[control.selectedSegmentIndex]
            }
        }
    }
}

/// Liquid Glass Tab Bar sesuai desain UI/UX UnionTabView
public struct LiquidGlassTabBar: View {
    @Binding public var selectedTab: TabItem
    public var activeTint: Color
    public var inactiveTint: Color
    public var barTint: Color
    public var itemWidth: CGFloat
    public var itemHeight: CGFloat

    public init(
        selectedTab: Binding<TabItem>,
        activeTint: Color = Color(hex: "00F2FE"),
        inactiveTint: Color = Color.white.opacity(0.45),
        barTint: Color = Color.white.opacity(0.18),
        itemWidth: CGFloat = 86,
        itemHeight: CGFloat = 56
    ) {
        self._selectedTab = selectedTab
        self.activeTint = activeTint
        self.inactiveTint = inactiveTint
        self.barTint = barTint
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(TabItem.allCases), id: \.self) { tab in
                let isSelected = (selectedTab == tab)

                VStack(spacing: 4) {
                    Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                        .font(.title3)
                        .symbolEffect(.bounce, value: isSelected)
                        .foregroundStyle(isSelected ? activeTint : inactiveTint)

                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isSelected ? activeTint : inactiveTint)
                }
                .frame(width: itemWidth, height: itemHeight)
            }
        }
        .background {
            GeometryReader { geometry in
                SegmentedControlTabBar(size: geometry.size, barTint: barTint, activeTab: $selectedTab)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.8
                        )
                }
        )
        .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }
}
