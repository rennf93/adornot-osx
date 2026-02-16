import SwiftUI

struct CategoryResultView: View {
    let category: TestCategory
    let results: [TestResult]

    @State private var isExpanded = false

    private var blockedCount: Int { results.filter(\.isBlocked).count }

    private var score: Double {
        results.isEmpty ? 0 : (Double(blockedCount) / Double(results.count)) * 100
    }

    private var scoreColor: Color {
        if score >= 60 { .green }
        else if score >= 30 { .orange }
        else { .red }
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            LazyVStack(spacing: 2) {
                ForEach(results.sorted(by: { $0.domain.provider < $1.domain.provider })) { result in
                    DomainResultRow(result: result)
                }
            }
        } label: {
            HStack {
                Image(systemName: category.systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.headline)
                    Text("\(blockedCount)/\(results.count) blocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(score))%")
                    .font(.title3.bold().monospacedDigit())
                    .foregroundStyle(scoreColor)
            }
        }
    }
}

#Preview {
    CategoryResultView(
        category: .ads,
        results: PreviewData.sampleAdsResults
    )
    .padding()
}
