import SwiftUI

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Theme.brandBlueLight)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

// MARK: - Warning Banner

struct WarningBanner: View {
    let icon: String
    var title: String?
    let message: String

    var body: some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(.body)
            if let title {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            } else {
                Text(message)
                    .font(.subheadline.weight(.medium))
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
