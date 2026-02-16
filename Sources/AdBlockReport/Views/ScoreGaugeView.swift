import SwiftUI

struct ScoreGaugeView: View {
    let score: Double
    let animateOnAppear: Bool

    @State private var displayedScore: Double = 0

    private var scoreColor: Color {
        if score >= 60 { .green }
        else if score >= 30 { .orange }
        else { .red }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 16)
                .foregroundStyle(.quaternary)

            Circle()
                .trim(from: 0, to: displayedScore / 100)
                .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .foregroundStyle(scoreColor)
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
        .onAppear {
            if animateOnAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    displayedScore = score
                }
            } else {
                displayedScore = score
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
