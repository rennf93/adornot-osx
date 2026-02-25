import SwiftUI

struct ResultsView: View {
    @Bindable var viewModel: TestViewModel
    @State private var showShareSheet = false
    @State private var appeared = false
    @State private var availableWidth: CGFloat = 600
    @State private var blocklistExpanded = false

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
                    // Pi-hole error banner
                    if let error = viewModel.piholeError {
                        piholeErrorBanner(error)
                    }

                    // Hero score
                    scoreHero
                        .padding(.top, viewModel.piholeError == nil ? Theme.spacingLG : 0)

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

                    // Per-blocklist breakdown (Pi-hole mode only)
                    if viewModel.testMode == .pihole {
                        blocklistBreakdown
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

                HStack(spacing: 4) {
                    Image(systemName: viewModel.testMode.systemImage)
                    Text(viewModel.testMode == .pihole ? "Pi-hole blocklist domains" : "Standard test")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    // MARK: - Blocklist Breakdown

    private var blocklistBreakdown: some View {
        let piholeResults = viewModel.results.filter { $0.domain.category == .piholeBlocklists }
        let byList = Dictionary(grouping: piholeResults, by: { $0.domain.provider })
        let sorted = byList.sorted { a, b in
            let aScore = Double(a.value.filter(\.isBlocked).count) / Double(a.value.count)
            let bScore = Double(b.value.filter(\.isBlocked).count) / Double(b.value.count)
            return aScore > bScore
        }

        return VStack(spacing: Theme.spacingMD) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    blocklistExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Blocklist Breakdown")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(byList.count) lists")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .rotationEffect(.degrees(blocklistExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            if blocklistExpanded {
                ForEach(Array(sorted.enumerated()), id: \.element.key) { index, item in
                    let blocked = item.value.filter(\.isBlocked).count
                    let total = item.value.count
                    let score = total > 0 ? Double(blocked) / Double(total) * 100 : 0

                    HStack(spacing: Theme.spacingSM) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.key)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text("\(blocked)/\(total) blocked")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        Spacer()

                        Text("\(Int(score))%")
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                            .foregroundStyle(ScoreThreshold.color(for: score))
                    }
                    .padding(Theme.spacingSM)
                    .background {
                        RoundedRectangle(cornerRadius: Theme.radiusSM)
                            .fill(.white.opacity(0.05))
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
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

    // MARK: - Pi-hole Error Banner

    private func piholeErrorBanner(_ error: String) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.body)
            VStack(alignment: .leading, spacing: 2) {
                Text("Pi-hole Connection Error")
                    .font(.subheadline.weight(.semibold))
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(Theme.spacingMD)
        .background {
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.scoreWeak.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .strokeBorder(Theme.scoreWeak.opacity(0.5), lineWidth: 1)
                )
        }
        .padding(.top, Theme.spacingMD)
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
