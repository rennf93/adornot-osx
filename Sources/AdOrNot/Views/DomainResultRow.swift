import SwiftUI

struct DomainResultRow: View {
    let result: TestResult
    @Environment(\.uiScale) private var uiScale

    var body: some View {
        HStack(spacing: Theme.spacingSM) {
            // Status icon with colored background
            ZStack {
                Circle()
                    .fill(result.isBlocked
                          ? Theme.scoreGood.opacity(0.15)
                          : Theme.scoreWeak.opacity(0.15))
                    .frame(width: Theme.scaled(Theme.statusCircleSize, by: uiScale), height: Theme.scaled(Theme.statusCircleSize, by: uiScale))

                Image(systemName: result.isBlocked ? "checkmark" : "xmark")
                    .font(Theme.fontIconSM(uiScale))
                    .foregroundStyle(result.isBlocked ? Theme.scoreGood : Theme.scoreWeak)
            }

            // Domain info
            VStack(alignment: .leading, spacing: 1) {
                Text(result.domain.hostname)
                    .font(Theme.scaledCaption(uiScale).monospaced())
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(result.domain.provider)
                    .font(Theme.scaledCaption2(uiScale))
                    .foregroundStyle(.white.opacity(0.35))
            }

            Spacer()

            // Response time
            if let ms = result.responseTimeMs, !result.isBlocked {
                Text("\(Int(ms))ms")
                    .font(Theme.scaledCaption2(uiScale).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, Theme.scaled(Theme.badgePaddingH, by: uiScale))
                    .padding(.vertical, Theme.scaled(Theme.badgePaddingV, by: uiScale))
                    .background {
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                    }
            }
        }
        .padding(.vertical, Theme.spacingXS)
        .padding(.horizontal, Theme.spacingMD)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.domain.provider), \(result.domain.hostname), \(result.isBlocked ? "blocked" : "exposed")")
    }
}

#Preview("Blocked") {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        VStack {
            DomainResultRow(result: TestResult(
                domain: TestDomain(hostname: "pagead2.googlesyndication.com", provider: "Google Ads", category: .ads),
                isBlocked: true
            ))
            DomainResultRow(result: TestResult(
                domain: TestDomain(hostname: "analytics.google.com", provider: "Google Analytics", category: .analytics),
                isBlocked: false,
                responseTimeMs: 142
            ))
        }
        .glassCard()
    }
}
