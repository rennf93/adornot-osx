import SwiftUI

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String
    @Environment(\.uiScale) private var uiScale

    var body: some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(Theme.scaledSubheadline(uiScale))
                .foregroundStyle(Theme.brandBlueLight)
            Text(title)
                .font(Theme.scaledSubheadline(uiScale).weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

// MARK: - Warning Banner

struct WarningBanner: View {
    let icon: String
    var title: String?
    let message: String
    @Environment(\.uiScale) private var uiScale

    var body: some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(Theme.scaledBody(uiScale))
            if let title {
                VStack(alignment: .leading, spacing: Theme.spacingXXS) {
                    Text(title)
                        .font(Theme.scaledSubheadline(uiScale).weight(.semibold))
                    Text(message)
                        .font(Theme.scaledCaption(uiScale))
                        .foregroundStyle(.white.opacity(0.7))
                }
            } else {
                Text(message)
                    .font(Theme.scaledSubheadline(uiScale).weight(.medium))
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingSM)
        .background {
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.scoreWeak.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .strokeBorder(Theme.scoreWeak.opacity(0.5), lineWidth: 1)
                )
        }
    }
}

// MARK: - Styled Divider

struct StyledDivider: View {
    var body: some View {
        Divider()
            .overlay(Color.white.opacity(0.06))
    }
}
