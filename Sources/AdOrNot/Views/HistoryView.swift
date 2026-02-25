import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \TestReport.date, order: .reverse)
    private var reports: [TestReport]

    @Environment(\.modelContext) private var modelContext
    @State private var availableWidth: CGFloat = 600

    private var historyColumnCount: Int {
        Theme.responsiveColumnCount(
            availableWidth: availableWidth,
            minColumns: 3,
            idealItemWidth: 200
        )
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            if reports.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Theme.flexibleColumns(count: historyColumnCount),
                        spacing: Theme.spacingMD
                    ) {
                        ForEach(reports) { report in
                            NavigationLink(destination: HistoryDetailView(report: report)) {
                                reportCard(report)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    withAnimation {
                                        modelContext.delete(report)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingMD)
                    .frame(maxWidth: 1200)
                    .frame(maxWidth: .infinity)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.width
                    } action: { newWidth in
                        availableWidth = newWidth
                    }
                }
            }
        }
        .navigationTitle("History")
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Theme.spacingLG) {
            ZStack {
                Circle()
                    .fill(Theme.brandBlue.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .blur(radius: 15)

                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.brandBlueLight.opacity(0.5))
            }

            VStack(spacing: Theme.spacingSM) {
                Text("No Test History")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text("Run your first test to see results here.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Report Card

    private func reportCard(_ report: TestReport) -> some View {
        VStack(spacing: Theme.spacingSM) {
            ScoreGaugeView(
                score: report.overallScore,
                animateOnAppear: false,
                size: 50,
                showGlow: false
            )

            Text("\(Int(report.overallScore))%")
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(ScoreThreshold.color(for: report.overallScore))

            Text(report.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text("\(report.blockedDomains)/\(report.totalDomains) blocked")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))

            HStack(spacing: 2) {
                Image(systemName: report.testModeEnum.systemImage)
                Text(report.testModeEnum.label)
            }
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingMD)
        .glassCard(padding: Theme.spacingSM)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(.preview)
}
