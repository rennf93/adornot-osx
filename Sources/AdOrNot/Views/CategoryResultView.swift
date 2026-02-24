import SwiftUI

struct CategoryResultView: View {
    let category: TestCategory
    let results: [TestResult]
    var isCompact: Bool = false

    @State private var isExpanded = false

    private var blockedCount: Int { results.filter(\.isBlocked).count }

    private var score: Double {
        results.isEmpty ? 0 : (Double(blockedCount) / Double(results.count)) * 100
    }

    var body: some View {
        VStack(spacing: 0) {
            if isCompact {
                compactHeader
            } else {
                // Header (tappable)
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isExpanded.toggle()
                    }
                } label: {
                    categoryHeader
                }
                .buttonStyle(.plain)

                // Expandable content
                if isExpanded {
                    VStack(spacing: 0) {
                        Divider()
                            .overlay(Color.white.opacity(0.06))

                        LazyVStack(spacing: 0) {
                            ForEach(results.sorted(by: { $0.domain.provider < $1.domain.provider })) { result in
                                DomainResultRow(result: result)
                            }
                        }
                        .padding(.vertical, Theme.spacingSM)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .glassCard(padding: 0)
    }

    // MARK: - Compact Header (for grid layout)

    private var compactHeader: some View {
        VStack(spacing: Theme.spacingSM) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.radiusSM)
                    .fill(Theme.brandBlue.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: category.systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.brandBlueLight)
            }

            Text(category.rawValue)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(Int(score))%")
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(ScoreThreshold.color(for: score))

            Text("\(blockedCount)/\(results.count) blocked")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ScoreThreshold.color(for: score))
                        .frame(width: geo.size.width * (score / 100))
                }
            }
            .frame(height: 4)
            .padding(.horizontal, Theme.spacingSM)
        }
        .padding(Theme.spacingMD)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.rawValue), \(blockedCount) of \(results.count) blocked, \(Int(score))%")
    }

    // MARK: - Expandable Header (for list layout)

    private var categoryHeader: some View {
        HStack(spacing: Theme.spacingSM) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: Theme.radiusSM)
                    .fill(Theme.brandBlue.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: category.systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.brandBlueLight)
            }

            // Category info
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(blockedCount)/\(results.count) blocked")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Score + progress
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(score))%")
                    .font(.title3.bold().monospacedDigit())
                    .foregroundStyle(ScoreThreshold.color(for: score))

                // Mini progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.08))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(ScoreThreshold.color(for: score))
                            .frame(width: geo.size.width * (score / 100))
                    }
                }
                .frame(width: 60, height: 4)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.3))
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(Theme.spacingMD)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.rawValue), \(blockedCount) of \(results.count) blocked, \(Int(score))%")
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        CategoryResultView(
            category: .ads,
            results: PreviewData.sampleAdsResults
        )
        .padding()
    }
}
