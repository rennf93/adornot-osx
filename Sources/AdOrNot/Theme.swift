import SwiftUI

// MARK: - Design System

/// Centralized design system for the AdOrNot app.
/// Provides a rich blue color palette, gradients, spacing, and reusable modifiers.
enum Theme {

    // MARK: - Colors

    /// Primary brand blue — deeper and more saturated than system blue.
    static let brandBlue = Color(red: 0.22, green: 0.42, blue: 0.95)

    /// Lighter brand blue for accents and highlights.
    static let brandBlueLight = Color(red: 0.38, green: 0.58, blue: 1.0)

    /// Deep navy for dark backgrounds and headers.
    static let brandNavy = Color(red: 0.08, green: 0.12, blue: 0.28)

    /// Very deep navy for the darkest backgrounds.
    static let brandNavyDeep = Color(red: 0.04, green: 0.06, blue: 0.18)

    /// Soft indigo tint for secondary accents.
    static let brandIndigo = Color(red: 0.32, green: 0.30, blue: 0.90)

    /// Soft cyan for tertiary accents and chart elements.
    static let brandCyan = Color(red: 0.25, green: 0.72, blue: 0.95)

    /// Surface color for cards.
    #if os(macOS)
    static let cardSurface = Color(.windowBackgroundColor).opacity(0.6)
    #else
    static let cardSurface = Color(.systemBackground).opacity(0.6)
    #endif

    /// Score colors.
    static let scoreGood = Color(red: 0.20, green: 0.78, blue: 0.45)
    static let scoreModerate = Color(red: 0.95, green: 0.65, blue: 0.15)
    static let scoreWeak = Color(red: 0.92, green: 0.30, blue: 0.25)

    // MARK: - Gradients

    /// Hero background gradient — deep navy to indigo.
    static let backgroundGradient = LinearGradient(
        colors: [brandNavyDeep, brandNavy, Color(red: 0.10, green: 0.14, blue: 0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Primary button gradient.
    static let buttonGradient = LinearGradient(
        colors: [brandBlue, brandIndigo],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Score gauge gradient (good score).
    static let gaugeGoodGradient = LinearGradient(
        colors: [scoreGood, Color(red: 0.15, green: 0.85, blue: 0.55)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Score gauge gradient (moderate score).
    static let gaugeModerateGradient = LinearGradient(
        colors: [scoreModerate, Color(red: 1.0, green: 0.75, blue: 0.20)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Score gauge gradient (weak score).
    static let gaugeWeakGradient = LinearGradient(
        colors: [scoreWeak, Color(red: 0.95, green: 0.40, blue: 0.30)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle card gradient for glass effect.
    static let glassGradient = LinearGradient(
        colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // MARK: - Corner Radius

    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 20

    // MARK: - Animation Durations

    static let animationQuick: Double = 0.15
    static let animationDefault: Double = 0.25
    static let animationGaugeFill: Double = 1.2

    // MARK: - Typography

    static let fontDisplayTitle: Font = .system(size: 28, weight: .bold, design: .rounded)
    static let fontPageTitle: Font = .system(size: 24, weight: .bold, design: .rounded)
    static let fontScoreLabel: Font = .system(size: 18, weight: .semibold, design: .rounded)
    static let fontIconMD: Font = .system(size: 16)
    static let fontSidebarTitle: Font = .system(size: 14, weight: .bold, design: .rounded)
    static let fontSidebarItem: Font = .system(size: 13, weight: .medium)
    static let fontCode: Font = .system(size: 11, design: .monospaced)
    static let fontIconSM: Font = .system(size: 11, weight: .bold)
    static let fontBadge: Font = .system(size: 9, weight: .medium)

    static func fontHeroTitle(forWidth width: CGFloat, scale: CGFloat = 1.0) -> Font {
        .system(size: min(28, max(18, width * 0.045)) * scale, weight: .bold, design: .rounded)
    }
    static func fontGaugeScore(forSize size: CGFloat) -> Font {
        .system(size: size * 0.22, weight: .bold, design: .rounded)
    }
    static func fontGaugeSubtitle(forSize size: CGFloat) -> Font {
        .system(size: max(9, size * 0.06))
    }
    static func fontRingCount(forSize size: CGFloat) -> Font {
        .system(size: max(11, size * 0.07))
    }

    // MARK: - Element Sizes

    static let iconSizeXL: CGFloat = 44
    static let iconContainerMD: CGFloat = 36
    static let iconContainerSM: CGFloat = 32
    static let statusCircleSize: CGFloat = 28
    static let logoSizeLG: CGFloat = 80
    static let logoSizeMD: CGFloat = 56
    static let logoSizeSM: CGFloat = 48
    static let logoSizeXS: CGFloat = 32
    static let sidebarIconWidth: CGFloat = 24
    static let miniProgressBarWidth: CGFloat = 60
    static let progressBarHeight: CGFloat = 4
    static let glowCircleSize: CGFloat = 100
    static let buttonMaxWidth: CGFloat = 280
    static let badgePaddingH: CGFloat = 6
    static let badgePaddingV: CGFloat = 2
    static let spacingXXS: CGFloat = 2

    // MARK: - Shadows

    static let shadowColor = Color.black.opacity(0.15)
    static let shadowRadius: CGFloat = 12
    static let glowColor = brandBlue.opacity(0.3)

    // MARK: - Responsive Scaling

    /// Computes a scale factor (1.0–1.5) based on the detail pane width.
    static func scaleFactor(forDetailWidth width: CGFloat) -> CGFloat {
        let minWidth: CGFloat = 520
        let maxWidth: CGFloat = 1000
        let t = (min(max(width, minWidth), maxWidth) - minWidth) / (maxWidth - minWidth)
        return 1.0 + t * 0.5
    }

    /// Scales a value by the given factor.
    static func scaled(_ value: CGFloat, by scale: CGFloat) -> CGFloat {
        value * scale
    }

    // MARK: - Scaled Typography

    static func fontDisplayTitle(_ s: CGFloat) -> Font { .system(size: 28 * s, weight: .bold, design: .rounded) }
    static func fontPageTitle(_ s: CGFloat) -> Font { .system(size: 24 * s, weight: .bold, design: .rounded) }
    static func fontScoreLabel(_ s: CGFloat) -> Font { .system(size: 18 * s, weight: .semibold, design: .rounded) }
    static func fontIconMD(_ s: CGFloat) -> Font { .system(size: 16 * s) }
    static func fontCode(_ s: CGFloat) -> Font { .system(size: 11 * s, design: .monospaced) }
    static func fontIconSM(_ s: CGFloat) -> Font { .system(size: 11 * s, weight: .bold) }
    static func fontBadge(_ s: CGFloat) -> Font { .system(size: 9 * s, weight: .medium) }

    // MARK: - Scaled Semantic Fonts

    static func scaledHeadline(_ s: CGFloat) -> Font { .system(size: 13 * s, weight: .semibold) }
    static func scaledSubheadline(_ s: CGFloat) -> Font { .system(size: 11 * s) }
    static func scaledBody(_ s: CGFloat) -> Font { .system(size: 13 * s) }
    static func scaledCaption(_ s: CGFloat) -> Font { .system(size: 10 * s) }
    static func scaledCaption2(_ s: CGFloat) -> Font { .system(size: 9 * s) }
    static func scaledTitle3(_ s: CGFloat) -> Font { .system(size: 15 * s, weight: .bold) }

    // MARK: - Helpers

    /// Returns the appropriate gauge gradient for a given score.
    static func gaugeGradient(for score: Double) -> LinearGradient {
        if score >= ScoreThreshold.good { return gaugeGoodGradient }
        else if score >= ScoreThreshold.moderate { return gaugeModerateGradient }
        else { return gaugeWeakGradient }
    }

    /// Returns the appropriate glow color for a given score.
    static func glowColor(for score: Double) -> Color {
        if score >= ScoreThreshold.good { return scoreGood.opacity(0.4) }
        else if score >= ScoreThreshold.moderate { return scoreModerate.opacity(0.4) }
        else { return scoreWeak.opacity(0.4) }
    }

    // MARK: - Responsive Grid

    /// Calculates the number of grid columns based on available width.
    static func responsiveColumnCount(
        availableWidth: CGFloat,
        minColumns: Int,
        idealItemWidth: CGFloat
    ) -> Int {
        let count = Int(availableWidth / idealItemWidth)
        return max(minColumns, count)
    }

    /// Creates an array of flexible GridItems for use with LazyVGrid.
    static func flexibleColumns(
        count: Int,
        spacing: CGFloat = spacingMD
    ) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
}

// MARK: - UI Scale Environment Key

private struct UIScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

extension EnvironmentValues {
    var uiScale: CGFloat {
        get { self[UIScaleKey.self] }
        set { self[UIScaleKey.self] = newValue }
    }
}

// MARK: - Glass Card Modifier

struct GlassCard: ViewModifier {
    var padding: CGFloat = Theme.spacingMD

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusLG)
                            .fill(Theme.glassGradient)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusLG)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: 4)
    }
}

extension View {
    func glassCard(padding: CGFloat = Theme.spacingMD) -> some View {
        modifier(GlassCard(padding: padding))
    }
}

// MARK: - Gradient Button Style

struct GradientButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    var scale: CGFloat = 1.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.scaledHeadline(scale))
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.scaled(Theme.spacingXL, by: scale))
            .padding(.vertical, Theme.scaled(Theme.spacingMD, by: scale))
            .background {
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(Theme.buttonGradient)
                    .opacity(isDisabled ? 0.4 : 1)
                    .shadow(color: Theme.brandBlue.opacity(configuration.isPressed ? 0.1 : 0.35),
                            radius: configuration.isPressed ? 4 : 10, y: 4)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: Theme.animationQuick), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    var scale: CGFloat = 1.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.scaledHeadline(scale))
            .foregroundStyle(Theme.brandBlue)
            .padding(.horizontal, Theme.scaled(Theme.spacingXL, by: scale))
            .padding(.vertical, Theme.scaled(Theme.spacingMD, by: scale))
            .background {
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .strokeBorder(Theme.brandBlue.opacity(0.3), lineWidth: 1)
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: Theme.animationQuick), value: configuration.isPressed)
    }
}

// MARK: - Animated Background

struct AnimatedMeshBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            // Subtle animated orbs for visual depth
            Circle()
                .fill(Theme.brandBlue.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -100, y: -200 + sin(phase) * 20)

            Circle()
                .fill(Theme.brandIndigo.opacity(0.06))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 120, y: 100 + cos(phase) * 15)

            Circle()
                .fill(Theme.brandCyan.opacity(0.05))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: -80, y: 200 + sin(phase * 0.7) * 25)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    @Environment(\.uiScale) private var uiScale

    var body: some View {
        VStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(Theme.scaledTitle3(uiScale))
                .foregroundStyle(Theme.brandBlueLight)
            Text(value)
                .font(Theme.scaledTitle3(uiScale).monospacedDigit())
                .foregroundStyle(.white)
            Text(title)
                .font(Theme.scaledCaption(uiScale))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .glassCard(padding: Theme.spacingMD)
    }
}
