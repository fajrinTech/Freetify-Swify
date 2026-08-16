import SwiftUI

// MARK: - Apple Ultra-Realistic Liquid Glass & Material Modifiers (Ref: Ricky Aguilar / Apple HIG)

/// Modifier Kartu Kaca Cair (Liquid Glass Card) dengan pembiasan dinamis, dual-layer specular highlight, dan hairline specular border
public struct LiquidGlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var tintColor: Color
    public var borderGradient: LinearGradient

    public init(
        cornerRadius: CGFloat = 24,
        tintColor: Color = Color(hex: "0D1117").opacity(0.85),
        borderGradient: LinearGradient = LinearGradient(
            colors: [
                Color.white.opacity(0.45),
                Color(hex: "00F2FE").opacity(0.20),
                Color.white.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    ) {
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.borderGradient = borderGradient
    }

    public func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tintColor)
                    }
                    .overlay {
                        // 1. Specular Top Lens Glare Reflection (Pantulan Kaca Khas Apple)
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
            }
            .overlay {
                // 2. Hairline Optical Specular Border
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(borderGradient, lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 7)
    }
}

/// Modifier Kapsul Kaca Cair Melayang (Liquid Glass Capsule) untuk Floating Navigation & Action Buttons
public struct LiquidGlassCapsuleModifier: ViewModifier {
    public var tintColor: Color
    public var borderGradient: LinearGradient

    public init(
        tintColor: Color = Color(hex: "0B0E14").opacity(0.88),
        borderGradient: LinearGradient = LinearGradient(
            colors: [
                Color.white.opacity(0.50),
                Color(hex: "00F2FE").opacity(0.25),
                Color.white.opacity(0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    ) {
        self.tintColor = tintColor
        self.borderGradient = borderGradient
    }

    public func body(content: Content) -> some View {
        content
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(tintColor)
                    }
                    .overlay {
                        // Specular Light Sheen di bagian atas capsule
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.26),
                                Color.white.opacity(0.06),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                        .clipShape(Capsule())
                    }
            }
            .overlay {
                Capsule()
                    .strokeBorder(borderGradient, lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 8)
    }
}

/// Modifier Tombol Kaca Cair Interaktif (Liquid Glass Button)
public struct LiquidGlassButtonModifier: ViewModifier {
    public var tintColor: Color
    public var cornerRadius: CGFloat

    public init(
        tintColor: Color = Color.white.opacity(0.12),
        cornerRadius: CGFloat = 16
    ) {
        self.tintColor = tintColor
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tintColor)
                    }
                    .overlay {
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
            }
    }
}

// MARK: - View Extensions for Liquid Glass
extension View {
    /// Menerapkan efek Liquid Glass Card dengan specular highlight dan border gradient optik
    public func liquidGlassCard(
        cornerRadius: CGFloat = 24,
        tint: Color = Color(hex: "0D1117").opacity(0.85)
    ) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, tintColor: tint))
    }

    /// Menerapkan efek Ultra Floating Liquid Glass Capsule untuk TabBar dan Floating Action Bars
    public func liquidGlassCapsule(
        tint: Color = Color(hex: "0B0E14").opacity(0.88)
    ) -> some View {
        self.modifier(LiquidGlassCapsuleModifier(tintColor: tint))
    }

    /// Menerapkan efek Liquid Glass Button untuk tombol interaktif
    public func liquidGlassButton(
        tint: Color = Color.white.opacity(0.12),
        cornerRadius: CGFloat = 16
    ) -> some View {
        self.modifier(LiquidGlassButtonModifier(tintColor: tint, cornerRadius: cornerRadius))
    }
}
