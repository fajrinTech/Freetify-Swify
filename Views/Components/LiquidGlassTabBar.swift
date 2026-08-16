import SwiftUI

/// Floating 3D Chromatic Liquid Glass Bubble TabBar (100% Persis Gaya Telegram iOS - Gambar 2)
/// Dilengkapi lensa kaca cair cembung tembus pandang, dispersi prisma pelangi ganda, dan pelacakan usap 1:1 tanpa getaran
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
            let bubbleWidth = tabWidth * 0.96
            let selectedIndex = tabs.firstIndex(of: selectedTab) ?? 0
            let restingX = (CGFloat(selectedIndex) * tabWidth) + (tabWidth - bubbleWidth) / 2

            // Posisi X lensa kaca mengikuti jari 1:1 saat diusap, atau kembali ke tab aktif saat dilepas
            let bubbleX: CGFloat = {
                if let touchX = dragPositionX {
                    let clamped = max(0, min(touchX - bubbleWidth / 2, totalWidth - bubbleWidth))
                    return clamped
                }
                return restingX
            }()

            ZStack(alignment: .leading) {
                // 1. Dark Frosted Glass Base Track (Kapsul Lintasan Gelap)
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(Color(hex: "0A0D14").opacity(0.90))
                    }
                    .overlay {
                        // Hairline Specular Border Kaca Luar
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.28), Color.white.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .frame(height: 60)
                    .shadow(color: Color.black.opacity(0.55), radius: 14, x: 0, y: 7)

                // 2. 3D Chromatic Liquid Glass Lens (Lensa Kaca Pembesar Tembus Pandang Persis Telegram iOS)
                telegramLiquidGlassOrb(width: bubbleWidth, height: 66)
                    .offset(x: bubbleX)
                    .scaleEffect(isTouching ? 1.04 : 1.0, anchor: .center)
                    .animation(isTouching ? .interactiveSpring(response: 0.14, dampingFraction: 0.88) : .spring(response: 0.32, dampingFraction: 0.74), value: bubbleX)

                // 3. Tab Items (Ikon & Label)
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        let isSelected = (selectedTab == tab)

                        VStack(spacing: 2) {
                            Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                                .font(.system(size: isSelected ? 22 : 18, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(
                                    isSelected
                                        ? LinearGradient(
                                            colors: [Color(hex: "2979FF"), Color(hex: "00E5FF")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        : LinearGradient(
                                            colors: [Color.white.opacity(0.52), Color.white.opacity(0.52)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                                // Efek pembesaran optik ketika ikon berada di bawah lensa kaca
                                .scaleEffect(isSelected ? 1.18 : 1.0)
                                .animation(.spring(response: 0.28, dampingFraction: 0.74), value: isSelected)

                            Text(tab.title)
                                .font(.system(size: 11, weight: isSelected ? .heavy : .semibold))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.50))
                        }
                        .frame(width: tabWidth, height: 60)
                    }
                }
            }
            .frame(height: 60)
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

                        withAnimation(.spring(response: 0.32, dampingFraction: 0.74)) {
                            selectedTab = tabs[safeIndex]
                            dragPositionX = nil
                            isTouching = false
                        }
                    }
            )
        }
        .frame(height: 66)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    // MARK: - Telegram iOS 3D Chromatic Liquid Glass Orb (Persis Gambar 2)
    @ViewBuilder
    private func telegramLiquidGlassOrb(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // A. Lensa Kaca Bening Tembus Pandang 100% (Ultra Thin Clear Material)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                }

            // B. Dispersi Prisma Pelangi Atas (Warm Rainbow Prism Arc - Merah/Kuning/Hijau)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(hex: "FF2A6D").opacity(0.85),
                            Color(hex: "FFD000").opacity(0.95),
                            Color(hex: "00FFB2").opacity(0.90),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2.2
                )
                .mask {
                    VStack {
                        Rectangle()
                            .frame(height: height * 0.45)
                        Spacer()
                    }
                }
                .blur(radius: 0.8)

            // C. Dispersi Prisma Pelangi Bawah (Cool Rainbow Prism Arc - Biru/Cyan/Violet)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(hex: "0091FF").opacity(0.90),
                            Color(hex: "7928CA").opacity(0.85),
                            Color(hex: "FF007A").opacity(0.75),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2.2
                )
                .mask {
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: height * 0.45)
                    }
                }
                .blur(radius: 0.8)

            // D. Specular Top Crescent Lens Glare (Kilau Pantulan Kaca Cembung 3D Khas Apple)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.80),
                            Color.white.opacity(0.18),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(2)

            // E. Garis Tepi Kaca Halus Transparan (Specular Hairline Edge)
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.85),
                            Color.white.opacity(0.20),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
        }
        .frame(width: width, height: height)
        // Natural Contact Glass Shadow (Bebas dari warna biru luar mentereng)
        .shadow(color: Color.black.opacity(0.45), radius: 10, x: 0, y: 5)
    }
}
