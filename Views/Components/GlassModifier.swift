import SwiftUI

// MARK: - Apple Ultra-Realistic Liquid Glass & Material Modifiers

public struct LiquidGlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var tintColor: Color
    public var borderGradient: LinearGradient

    public init(
        cornerRadius: CGFloat = 24,
        tintColor: Color = Color.white.opacity(0.08),
        borderGradient: LinearGradient = LinearGradient(
            colors: [.white.opacity(0.4), .white.opacity(0.08)],
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
                        // Specular Top Light Reflection
                        LinearGradient(
                            colors: [Color.white.opacity(0.14), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(borderGradient, lineWidth: 1)
            }
    }
}

public struct LiquidGlassCapsuleModifier: ViewModifier {
    public var tintColor: Color
    public var borderGradient: LinearGradient

    public init(
        tintColor: Color = Color(hex: "0D1117").opacity(0.82),
        borderGradient: LinearGradient = LinearGradient(
            colors: [.white.opacity(0.45), .white.opacity(0.12)],
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
                            colors: [Color.white.opacity(0.20), Color.clear],
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
    }
}

// MARK: - View Extension for Liquid Glass
extension View {
    /// Menerapkan efek Liquid Glass Card dengan specular highlight dan border gradient optik
    public func liquidGlassCard(
        cornerRadius: CGFloat = 24,
        tint: Color = Color.white.opacity(0.08)
    ) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, tintColor: tint))
    }

    /// Menerapkan efek Ultra Floating Liquid Glass Capsule untuk TabBar dan Floating Buttons
    public func liquidGlassCapsule(
        tint: Color = Color(hex: "0D1117").opacity(0.82)
    ) -> some View {
        self.modifier(LiquidGlassCapsuleModifier(tintColor: tint))
    }
}
