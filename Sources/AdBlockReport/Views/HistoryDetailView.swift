import SwiftUI

struct HistoryDetailView: View {
    let report: TestReport
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ScoreGaugeView(score: report.overallScore, animateOnAppear: false)

                VStack(spacing: 4) {
                    Text(report.date.formatted(date: .long, time: .shortened))
                        .font(.headline)
                    Text("\(report.deviceName) \u{2014} \(report.osVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Duration: \(String(format: "%.1f", report.durationSeconds))s")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Divider()

                let results = report.results
                let grouped = Dictionary(grouping: results, by: { $0.domain.category })
                ForEach(TestCategory.allCases) { category in
                    if let catResults = grouped[category], !catResults.isEmpty {
                        CategoryResultView(category: category, results: catResults)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Test Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(text: ExportService.generateTextReport(report))
        }
    }
}
