import SwiftUI

struct TestingView: View {
    @Bindable var viewModel: TestViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(lineWidth: 12)
                    .foregroundStyle(.quaternary)

                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .foregroundStyle(.tint)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress)

                VStack(spacing: 4) {
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())

                    Text("\(viewModel.completedCount)/\(viewModel.totalCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 200, height: 200)

            VStack(spacing: 8) {
                Text("Testing...")
                    .font(.headline)

                Text(viewModel.currentDomain)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Text(formatDuration(viewModel.elapsedTime))
                .font(.caption)
                .foregroundStyle(.tertiary)
                .monospacedDigit()

            Spacer()

            Button("Cancel", role: .cancel) {
                viewModel.cancelTest()
            }
            .padding(.bottom, 40)
        }
        .padding()
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    TestingView(viewModel: PreviewData.makeRunningViewModel())
}
