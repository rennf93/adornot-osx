import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \TestReport.date, order: .reverse)
    private var reports: [TestReport]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            if reports.isEmpty {
                ContentUnavailableView(
                    "No Test History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Run your first test to see results here.")
                )
            } else {
                ForEach(reports) { report in
                    NavigationLink(destination: HistoryDetailView(report: report)) {
                        HStack {
                            ScoreGaugeView(score: report.overallScore, animateOnAppear: false)
                                .frame(width: 50, height: 50)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(report.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.headline)
                                Text("\(report.blockedDomains)/\(report.totalDomains) blocked")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(Int(report.overallScore))%")
                                .font(.title3.bold().monospacedDigit())
                                .foregroundStyle(ScoreThreshold.color(for: report.overallScore))
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(reports[index])
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(.preview)
}
