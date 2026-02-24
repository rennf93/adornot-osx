import SwiftUI

struct ScoreGaugeView: View {
    let score: Double
    let animateOnAppear: Bool
    var size: CGFloat = 220
    var showGlow: Bool = true

    @State private var displayedScore: Double = 0

    private var scoreColor: Color {
        ScoreThreshold.color(for: score)
    }

    private var totalSize: CGFloat {
        showGlow ? size * 1.4 : size
    }

    var body: some View {
        ZStack {
            // Glow effect
            if showGlow {
                Circle()
                    .fill(Theme.glowColor(for: score))
                    .frame(width: size * 1.2, height: size * 1.2)
                    .blur(radius: size * 0.15)
                    .opacity(displayedScore > 0 ? 0.6 : 0)
            }

            // Background track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: size * 0.07)

            // Score arc with gradient
            Circle()
                .trim(from: 0, to: displayedScore / 100)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * (displayedScore / 100))
                    ),
                    style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: scoreColor.opacity(0.5), radius: 6)

            // Center content
            VStack(spacing: 2) {
                Text("\(Int(displayedScore))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text("blocked")
                    .font(.system(size: size * 0.06))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(width: totalSize, height: totalSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(score))% blocked")
        .accessibilityValue(ScoreThreshold.label(for: score))
        .onAppear {
            if animateOnAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    displayedScore = score
                }
            } else {
                displayedScore = score
            }
        }
        .onChange(of: score) { _, newValue in
            if animateOnAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    displayedScore = newValue
                }
            } else {
                displayedScore = newValue
            }
        }
    }

    private var gradientColors: [Color] {
        if score >= ScoreThreshold.good {
            return [Theme.scoreGood, Color(red: 0.15, green: 0.85, blue: 0.55)]
        } else if score >= ScoreThreshold.moderate {
            return [Theme.scoreModerate, Color(red: 1.0, green: 0.75, blue: 0.20)]
        } else {
            return [Theme.scoreWeak, Color(red: 0.95, green: 0.40, blue: 0.30)]
        }
    }
}

#Preview("High Score") {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        ScoreGaugeView(score: 82, animateOnAppear: true)
    }
}

#Preview("Medium Score") {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        ScoreGaugeView(score: 45, animateOnAppear: true)
    }
}

#Preview("Low Score") {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        ScoreGaugeView(score: 15, animateOnAppear: true)
    }
}

#Preview("Small") {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        ScoreGaugeView(score: 70, animateOnAppear: false, size: 50, showGlow: false)
    }
}
