import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    VStack(spacing: Theme.spacingMD) {
                        ZStack {
                            Circle()
                                .fill(Theme.brandBlue.opacity(0.15))
                                .frame(width: 100, height: 100)
                                .blur(radius: 15)

                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Text("AdOrNot")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, Theme.spacingLG)

                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        aboutParagraph(
                            title: nil,
                            text: "This app tests the effectiveness of your DNS-level ad blocker or content filter by attempting to reach known advertising, analytics, and tracking domains."
                        )

                        aboutParagraph(
                            title: "How It Works",
                            text: "For each domain in our curated list, the app sends an HTTP HEAD request. If the request fails because DNS resolution is blocked, the domain is counted as blocked. The percentage of blocked domains gives you a score indicating how effective your ad blocker is."
                        )

                        aboutParagraph(
                            title: "Domain Coverage",
                            text: "The domain list includes well-known ad networks (Google Ads, DoubleClick), analytics services (Google Analytics, Hotjar), social media trackers (Facebook Pixel, TikTok), and device manufacturer telemetry (Samsung, Xiaomi, Apple)."
                        )
                    }
                    .glassCard(padding: Theme.spacingMD)

                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundStyle(Theme.brandBlueLight)
                        Text("License: GPLv3")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                    }
                    .padding(.horizontal, Theme.spacingXS)
                }
                .padding(.horizontal, Theme.spacingLG)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 400, minHeight: 400)
    }

    private func aboutParagraph(title: String?, text: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Text(text)
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)
        }
    }
}

#Preview {
    AboutView()
}
