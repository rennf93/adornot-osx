import SwiftUI

struct ResultsView: View {
    @Bindable var viewModel: TestViewModel
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
                    scoreHero
                        .padding(.top, Theme.spacingLG)

                    // Summary stats
                    summaryStats

                    // Category breakdown
                    VStack(spacing: Theme.spacingMD) {
                        HStack {
                            Text("Category Breakdown")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }

                        LazyVGrid(
                            columns: Theme.flexibleColumns(count: categoryColumnCount),
                            spacing: Theme.spacingMD
                        ) {
                            ForEach(Array(viewModel.resultsByCategory.enumerated()), id: \.element.category) { index, item in
                                CategoryResultView(
                                    category: item.category,
                                    results: item.results,
                                    isCompact: true
                                )
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: appeared)
                            }
                        }
                    }

                    // Action buttons
                    actionButtons
                        .padding(.vertical, Theme.spacingMD)
                }
                .padding(.horizontal, Theme.spacingLG)
                .frame(maxWidth: 1200)
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newWidth in
                    availableWidth = newWidth
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let report = viewModel.latestReport {
                ShareSheet(text: ExportService.generateTextReport(report))
            }
        }
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }

    // MARK: - Score Hero

    private var scoreHero: some View {
        VStack(spacing: Theme.spacingMD) {
            ScoreGaugeView(score: viewModel.overallScore, animateOnAppear: true, size: gaugeSize)

            VStack(spacing: Theme.spacingXS) {
                Text(ScoreThreshold.label(for: viewModel.overallScore))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(ScoreThreshold.color(for: viewModel.overallScore))

                Text("\(viewModel.results.filter(\.isBlocked).count) of \(viewModel.results.count) domains blocked")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Summary Stats

    private var summaryStats: some View {
        HStack(spacing: Theme.spacingMD) {
            StatCard(
                title: "Blocked",
                value: "\(viewModel.results.filter(\.isBlocked).count)",
                icon: "checkmark.shield.fill"
            )
            StatCard(
                title: "Exposed",
                value: "\(viewModel.results.filter { !$0.isBlocked }.count)",
                icon: "exclamationmark.triangle.fill"
            )
            StatCard(
                title: "Categories",
                value: "\(viewModel.resultsByCategory.count)",
                icon: "folder.fill"
            )
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Theme.spacingMD) {
            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
            }
            .buttonStyle(SecondaryButtonStyle())

            Button {
                viewModel.reset()
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("New Test")
                }
                .frame(maxWidth: 200)
            }
            .buttonStyle(GradientButtonStyle())
        }
    }
}

#Preview {
    NavigationStack {
        ResultsView(viewModel: PreviewData.makeCompletedViewModel())
    }
}
