import SwiftUI

struct ResultsView: View {
    @Bindable var viewModel: TestViewModel
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ScoreGaugeView(score: viewModel.overallScore, animateOnAppear: true)
                    .padding(.top, 16)

                VStack(spacing: 4) {
                    Text(summaryText)
                        .font(.headline)
                    Text("\(viewModel.results.filter(\.isBlocked).count) of \(viewModel.results.count) domains blocked")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                ForEach(viewModel.resultsByCategory, id: \.category) { item in
                    CategoryResultView(
                        category: item.category,
                        results: item.results
                    )
                }

                HStack(spacing: 16) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        viewModel.reset()
                    } label: {
                        Label("New Test", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical)
            }
            .padding()
        }
        .sheet(isPresented: $showShareSheet) {
            if let report = viewModel.latestReport {
                ShareSheet(text: ExportService.generateTextReport(report))
            }
        }
    }

    private var summaryText: String {
        switch viewModel.scoreLevel {
        case .good: "Strong Protection"
        case .moderate: "Moderate Protection"
        case .poor: "Weak Protection"
        }
    }
}

#Preview {
    NavigationStack {
        ResultsView(viewModel: PreviewData.makeCompletedViewModel())
    }
}
