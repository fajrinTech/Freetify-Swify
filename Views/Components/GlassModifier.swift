import SwiftUI

// MARK: - Apple Liquid Glass & Material Fallback Modifiers

public struct LiquidGlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var tintColor: Color
    public var borderGradient: LinearGradient

    public init(
        cornerRadius: CGFloat = 24,
        tintColor: Color = Color.white.opacity(0.1),
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
        tintColor: Color = Color(hex: "12161C").opacity(0.85),
        borderGradient: LinearGradient = LinearGradient(
            colors: [.white.opacity(0.35), .white.opacity(0.08)],
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
            }
            .overlay {
                Capsule()
                    .strokeBorder(borderGradient, lineWidth: 1)
            }
    }
}

// MARK: - View Extension for Liquid Glass
extension View {
    /// Menerapkan efek Liquid Glass Card dengan pembatas melengkung dan border gradient optik
    public func liquidGlassCard(
        cornerRadius: CGFloat = 24,
        tint: Color = Color.white.opacity(0.08)
    ) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, tintColor: tint))
    }

    /// Menerapkan efek Liquid Glass Capsule untuk TabBar dan Floating Pill Buttons
    public func liquidGlassCapsule(
        tint: Color = Color(hex: "12161C").opacity(0.85)
    ) -> some View {
        self.modifier(LiquidGlassCapsuleModifier(tintColor: tint))
    }
}
