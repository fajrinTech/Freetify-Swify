import SwiftUI
import UIKit

/// Metrik dimensi Liquid Glass TabBar berbasis standar industri UnionTabView
public enum LiquidGlassTabBarMetrics {
    public static let contentHeight: CGFloat = 56
    public static let innerPadding: CGFloat = 4.67
    public static var totalHeight: CGFloat { contentHeight + (innerPadding * 2) }
    public static let restingBottomInset: CGFloat = 6
}

/// Representasi UIKit UISegmentedControl sebagai mesin penggerak gestur dan seleksi Liquid Glass bawaan iOS
@MainActor
public struct InteractiveGlassSegmentedControl: UIViewRepresentable {
    public var size: CGSize
    public var selectedIndex: Binding<Int>
    public var tabCount: Int
    public var barTint: Color
    public var onReselect: ((Int) -> Void)?

    public init(
        size: CGSize,
        selectedIndex: Binding<Int>,
        tabCount: Int,
        barTint: Color = .gray.opacity(0.15),
        onReselect: ((Int) -> Void)? = nil
    ) {
        self.size = size
        self.selectedIndex = selectedIndex
        self.tabCount = tabCount
        self.barTint = barTint
        self.onReselect = onReselect
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIView(context: Context) -> UISegmentedControl {
        let items = (0..<tabCount).map { _ in "" }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selectedIndex.wrappedValue
        control.selectedSegmentTintColor = UIColor(barTint)
        control.backgroundColor = .clear

        DispatchQueue.main.async {
            for subview in control.subviews {
                if subview is UIImageView && subview != control.subviews.last {
                    subview.alpha = 0
                }
            }
        }

        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.segmentChanged(_:)),
            for: .valueChanged
        )

        // Deteksi reselection (ketuk tab yang sedang aktif)
        let reselectRecognizer = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        reselectRecognizer.cancelsTouchesInView = false
        control.addGestureRecognizer(reselectRecognizer)

        return control
    }

    public func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        context.coordinator.parent = self
        if uiView.numberOfSegments != tabCount {
            uiView.removeAllSegments()
            for i in 0..<tabCount {
                uiView.insertSegment(withTitle: "", at: i, animated: false)
            }
        }
        if uiView.selectedSegmentIndex != selectedIndex.wrappedValue {
            uiView.selectedSegmentIndex = selectedIndex.wrappedValue
        }
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        size
    }

    public final class Coordinator: NSObject {
        var parent: InteractiveGlassSegmentedControl

        init(parent: InteractiveGlassSegmentedControl) {
            self.parent = parent
        }

        @MainActor @objc func segmentChanged(_ control: UISegmentedControl) {
            let newIndex = control.selectedSegmentIndex
            if newIndex >= 0 && newIndex < parent.tabCount && newIndex != parent.selectedIndex.wrappedValue {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                parent.selectedIndex.wrappedValue = newIndex
            }
        }

        @MainActor @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let control = gesture.view as? UISegmentedControl,
                  control.numberOfSegments > 0 else { return }

            let segmentWidth = control.bounds.width / CGFloat(control.numberOfSegments)
            guard segmentWidth > 0 else { return }

            let location = gesture.location(in: control)
            let index = min(control.numberOfSegments - 1, max(0, Int(location.x / segmentWidth)))

            if index == parent.selectedIndex.wrappedValue {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                parent.onReselect?(index)
            }
        }
    }
}

/// Floating Liquid Glass TabBar
/// Mengadopsi arsitektur terbaik dari UnionTabView, LiquidGlassCheatsheet, dan FabBar
public struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem
    @Environment(\.colorScheme) private var colorScheme
    public var onReselect: ((TabItem) -> Void)? = nil

    public init(
        selectedTab: Binding<TabItem>,
        onReselect: ((TabItem) -> Void)? = nil
    ) {
        self._selectedTab = selectedTab
        self.onReselect = onReselect
    }

    private let tabs = TabItem.allCases

    private var selectedIndexBinding: Binding<Int> {
        Binding(
            get: { selectedTab.id },
            set: { newId in
                if let newTab = TabItem(rawValue: newId) {
                    selectedTab = newTab
                }
            }
        )
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                let isSelected = (selectedTab == tab)

                VStack(spacing: 3) {
                    Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                        .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                        .symbolEffect(.bounce, value: isSelected)
                        .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)

                    Text(tab.title)
                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
                .frame(height: LiquidGlassTabBarMetrics.contentHeight)
                .contentShape(Rectangle())
            }
        }
        .allowsHitTesting(false)
        .background {
            GeometryReader { geo in
                InteractiveGlassSegmentedControl(
                    size: geo.size,
                    selectedIndex: selectedIndexBinding,
                    tabCount: tabs.count,
                    barTint: Color.white.opacity(0.20),
                    onReselect: { index in
                        if index < tabs.count {
                            onReselect?(tabs[index])
                        }
                    }
                )
            }
        }
        .padding(LiquidGlassTabBarMetrics.innerPadding)
        .background {
            // Container Kaca Kapsul dengan Convex Specular Highlight
            Capsule()
                .fill(Color(hex: "0D1117").opacity(0.88))
                .overlay {
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.35))
                }
                .overlay {
                    // Convex Specular Border: terang di atas, pudar di bawah
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
        }
        .shadow(color: Color.black.opacity(0.40), radius: 16, x: 0, y: 8)
        .frame(maxWidth: CGFloat(tabs.count) * 110)
        .padding(.horizontal, 20)
        .padding(.bottom, LiquidGlassTabBarMetrics.restingBottomInset)
    }
}
