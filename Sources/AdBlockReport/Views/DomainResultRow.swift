import SwiftUI

struct DomainResultRow: View {
    let result: TestResult

    var body: some View {
        HStack {
            Image(systemName: result.isBlocked ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(result.isBlocked ? .green : .red)

            VStack(alignment: .leading, spacing: 1) {
                Text(result.domain.hostname)
                    .font(.caption.monospaced())
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(result.domain.provider)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if let ms = result.responseTimeMs {
                Text("\(Int(ms))ms")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.domain.provider), \(result.domain.hostname), \(result.isBlocked ? "blocked" : "exposed")")
    }
}

#Preview("Blocked") {
    DomainResultRow(result: TestResult(
        domain: TestDomain(hostname: "pagead2.googlesyndication.com", provider: "Google Ads", category: .ads),
        isBlocked: true
    ))
}

#Preview("Exposed") {
    DomainResultRow(result: TestResult(
        domain: TestDomain(hostname: "analytics.google.com", provider: "Google Analytics", category: .analytics),
        isBlocked: false,
        responseTimeMs: 142
    ))
}
