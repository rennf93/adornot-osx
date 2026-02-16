import SwiftUI

struct ScoreGaugeView: View {
    let score: Double
    let animateOnAppear: Bool

    @State private var displayedScore: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 16)
                .foregroundStyle(.quaternary)

            Circle()
                .trim(from: 0, to: displayedScore / 100)
                .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .foregroundStyle(ScoreThreshold.color(for: score))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(Int(displayedScore))%")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Text("blocked")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
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
}

#Preview("High Score") {
    ScoreGaugeView(score: 82, animateOnAppear: true)
        .frame(width: 220, height: 220)
        .padding()
}

#Preview("Medium Score") {
    ScoreGaugeView(score: 45, animateOnAppear: true)
        .frame(width: 220, height: 220)
        .padding()
}

#Preview("Low Score") {
    ScoreGaugeView(score: 15, animateOnAppear: true)
        .frame(width: 220, height: 220)
        .padding()
}
