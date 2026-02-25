import SwiftUI

struct HistoryDetailView: View {
    let report: TestReport
    @State private var showShareSheet = false
    @State private var appeared = false
    @State private var availableWidth: CGFloat = 600

    private var gaugeSize: CGFloat {
        min(220, max(80, availableWidth * 0.35))
    }

    private var categoryColumnCount: Int {
        Theme.responsiveColumnCount(
            availableWidth: availableWidth,
            minColumns: 3,
            idealItemWidth: 200
        )
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    // Hero score
                    ScoreGaugeView(score: report.overallScore, animateOnAppear: false, size: gaugeSize)
                        .padding(.top, Theme.spacingMD)

                    // Device info card
                    deviceInfoCard

                    // Category breakdown
                    VStack(spacing: Theme.spacingMD) {
                        HStack {
                            Text("Category Breakdown")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }

                        let results = report.results
                        let grouped = Dictionary(grouping: results, by: { $0.domain.category })
                        LazyVGrid(
                            columns: Theme.flexibleColumns(count: categoryColumnCount),
                            spacing: Theme.spacingMD
                        ) {
                            ForEach(Array(TestCategory.allCases.enumerated()), id: \.element) { index, category in
                                if let catResults = grouped[category], !catResults.isEmpty {
                                    CategoryResultView(category: category, results: catResults, isCompact: true)
                                        .opacity(appeared ? 1 : 0)
                                        .offset(y: appeared ? 0 : 20)
                                        .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.06), value: appeared)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.spacingLG)
                .frame(maxWidth: 1200)
                .frame(maxWidth: .infinity)
                .padding(.bottom, Theme.spacingLG)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newWidth in
                    availableWidth = newWidth
                }
            }
        }
        .navigationTitle("Test Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Theme.brandBlueLight)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(text: ExportService.generateTextReport(report))
        }
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }

    // MARK: - Device Info Card

    private var deviceInfoCard: some View {
        HStack(spacing: Theme.spacingLG) {
            infoItem(
                icon: "calendar",
                label: "Date",
                value: report.date.formatted(date: .abbreviated, time: .shortened)
            )
            infoItem(
                icon: "desktopcomputer",
                label: "Device",
                value: report.deviceName
            )
            infoItem(
                icon: "gear",
                label: "OS",
                value: report.osVersion
            )
            infoItem(
                icon: "timer",
                label: "Duration",
                value: String(format: "%.1fs", report.durationSeconds)
            )
            infoItem(
                icon: report.testModeEnum.systemImage,
                label: "Mode",
                value: report.testModeEnum.label
            )
        }
        .glassCard(padding: Theme.spacingMD)
    }

    private func infoItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: Theme.spacingXS) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Theme.brandBlueLight)
            Text(value)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}
