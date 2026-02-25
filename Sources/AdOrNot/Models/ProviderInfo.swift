import Foundation

struct ProviderInfo: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let websiteURL: URL
}

enum ProviderRegistry {

    static let all: [String: ProviderInfo] = {
        let entries: [ProviderInfo] = [
            // MARK: - Ads

            ProviderInfo(
                id: "Amazon",
                name: "Amazon",
                description: "Cloud-hosted ad-serving and analytics endpoints used by Amazon's advertising platform.",
                websiteURL: URL(string: "https://advertising.amazon.com")!
            ),
            ProviderInfo(
                id: "Google Ads",
                name: "Google Ads",
                description: "Google's primary advertising platform serving display, search, and video ads.",
                websiteURL: URL(string: "https://ads.google.com")!
            ),
            ProviderInfo(
                id: "DoubleClick",
                name: "DoubleClick",
                description: "Google's ad-serving and campaign management technology for publishers and advertisers.",
                websiteURL: URL(string: "https://marketingplatform.google.com")!
            ),
            ProviderInfo(
                id: "AdColony",
                name: "AdColony",
                description: "Mobile video advertising platform specializing in in-app ad placements.",
                websiteURL: URL(string: "https://www.adcolony.com")!
            ),
            ProviderInfo(
                id: "Media.net",
                name: "Media.net",
                description: "Contextual advertising company powering the Yahoo! Bing Network ad marketplace.",
                websiteURL: URL(string: "https://www.media.net")!
            ),

            // MARK: - Analytics

            ProviderInfo(
                id: "Google Analytics",
                name: "Google Analytics",
                description: "Web analytics service tracking website traffic, user behavior, and conversions.",
                websiteURL: URL(string: "https://analytics.google.com")!
            ),
            ProviderInfo(
                id: "Hotjar",
                name: "Hotjar",
                description: "Behavior analytics tool providing heatmaps, session recordings, and user surveys.",
                websiteURL: URL(string: "https://www.hotjar.com")!
            ),
            ProviderInfo(
                id: "MouseFlow",
                name: "MouseFlow",
                description: "Session replay and heatmap analytics platform for understanding user behavior.",
                websiteURL: URL(string: "https://mouseflow.com")!
            ),
            ProviderInfo(
                id: "FreshWorks",
                name: "FreshWorks",
                description: "Marketing automation and analytics suite including Freshmarketer conversion tools.",
                websiteURL: URL(string: "https://www.freshworks.com")!
            ),
            ProviderInfo(
                id: "LuckyOrange",
                name: "LuckyOrange",
                description: "Conversion optimization suite with dynamic heatmaps, recordings, and live chat.",
                websiteURL: URL(string: "https://www.luckyorange.com")!
            ),
            ProviderInfo(
                id: "WordPress Stats",
                name: "WordPress Stats",
                description: "Built-in analytics for WordPress sites powered by Automattic's Jetpack.",
                websiteURL: URL(string: "https://wordpress.com/support/stats")!
            ),

            // MARK: - Error Trackers

            ProviderInfo(
                id: "Bugsnag",
                name: "Bugsnag",
                description: "Error monitoring and stability management platform for mobile and web applications.",
                websiteURL: URL(string: "https://www.bugsnag.com")!
            ),
            ProviderInfo(
                id: "Sentry",
                name: "Sentry",
                description: "Application performance monitoring and error tracking for software teams.",
                websiteURL: URL(string: "https://sentry.io")!
            ),

            // MARK: - Social Trackers

            ProviderInfo(
                id: "Facebook",
                name: "Facebook",
                description: "Meta's advertising pixel and audience network for cross-site user tracking.",
                websiteURL: URL(string: "https://www.facebook.com/business/tools/meta-pixel")!
            ),
            ProviderInfo(
                id: "Twitter",
                name: "Twitter",
                description: "X (formerly Twitter) advertising API and conversion tracking endpoints.",
                websiteURL: URL(string: "https://ads.x.com")!
            ),
            ProviderInfo(
                id: "LinkedIn",
                name: "LinkedIn",
                description: "Professional network's advertising and analytics tracking for B2B marketing.",
                websiteURL: URL(string: "https://business.linkedin.com/marketing-solutions/ads")!
            ),
            ProviderInfo(
                id: "Pinterest",
                name: "Pinterest",
                description: "Visual discovery platform's ad tracking and conversion measurement tags.",
                websiteURL: URL(string: "https://business.pinterest.com")!
            ),
            ProviderInfo(
                id: "Reddit",
                name: "Reddit",
                description: "Reddit's event tracking and conversion pixel for advertising campaigns.",
                websiteURL: URL(string: "https://ads.reddit.com")!
            ),
            ProviderInfo(
                id: "YouTube",
                name: "YouTube",
                description: "Google's video platform advertising and ad-serving endpoints.",
                websiteURL: URL(string: "https://www.youtube.com/ads")!
            ),
            ProviderInfo(
                id: "TikTok",
                name: "TikTok",
                description: "Short-form video platform's advertising SDK, analytics, and business API.",
                websiteURL: URL(string: "https://ads.tiktok.com")!
            ),

            // MARK: - Mix

            ProviderInfo(
                id: "Yahoo",
                name: "Yahoo",
                description: "Yahoo's combined advertising, analytics, and programmatic ad technology stack.",
                websiteURL: URL(string: "https://www.yahooinc.com/advertising")!
            ),
            ProviderInfo(
                id: "Yandex",
                name: "Yandex",
                description: "Russian search engine's advertising network and Metrica analytics platform.",
                websiteURL: URL(string: "https://yandex.com/adv")!
            ),
            ProviderInfo(
                id: "Unity",
                name: "Unity",
                description: "Game engine's built-in ad monetization platform for mobile games.",
                websiteURL: URL(string: "https://unity.com/products/unity-ads")!
            ),

            // MARK: - OEMs

            ProviderInfo(
                id: "Realme",
                name: "Realme",
                description: "Realme smartphone telemetry, IoT logging, and built-in advertising services.",
                websiteURL: URL(string: "https://www.realme.com")!
            ),
            ProviderInfo(
                id: "Xiaomi",
                name: "Xiaomi",
                description: "Xiaomi device telemetry, MIUI analytics, and built-in ad SDK configuration.",
                websiteURL: URL(string: "https://www.mi.com")!
            ),
            ProviderInfo(
                id: "Oppo",
                name: "Oppo",
                description: "Oppo smartphone advertising and analytics services embedded in ColorOS.",
                websiteURL: URL(string: "https://www.oppo.com")!
            ),
            ProviderInfo(
                id: "Huawei",
                name: "Huawei",
                description: "Huawei device metrics, cloud logging, and HiCloud telemetry services.",
                websiteURL: URL(string: "https://www.huawei.com")!
            ),
            ProviderInfo(
                id: "OnePlus",
                name: "OnePlus",
                description: "OnePlus device analytics and telemetry endpoints in OxygenOS.",
                websiteURL: URL(string: "https://www.oneplus.com")!
            ),
            ProviderInfo(
                id: "Samsung",
                name: "Samsung",
                description: "Samsung device metrics, advertising platform, and health analytics endpoints.",
                websiteURL: URL(string: "https://www.samsung.com")!
            ),
            ProviderInfo(
                id: "Apple",
                name: "Apple",
                description: "Apple's advertising attribution, iCloud metrics, and first-party app analytics.",
                websiteURL: URL(string: "https://searchads.apple.com")!
            ),
        ]
        return Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
    }()

    static func info(for providerName: String) -> ProviderInfo? {
        all[providerName]
    }
}
