# AdBlock Report

A native iOS and macOS app that tests the effectiveness of your DNS-level ad blocker or content filter.

## What It Does

Tests whether your ad blocker (Pi-hole, NextDNS, AdGuard, system content blockers, etc.) is effectively blocking known advertising, analytics, and tracking domains. The app attempts HTTP HEAD requests to ~131 well-known ad/tracking endpoints across 6 categories:

- **Ads** - Google Ads, DoubleClick, AdColony, Media.net, Amazon
- **Analytics** - Google Analytics, Hotjar, MouseFlow, FreshWorks, LuckyOrange
- **Error Trackers** - Bugsnag, Sentry
- **Social Trackers** - Facebook, Twitter, LinkedIn, Pinterest, Reddit, YouTube, TikTok
- **Mix** - Yahoo, Yandex, Unity
- **OEMs** - Realme, Xiaomi, Oppo, Huawei, OnePlus, Samsung, Apple

If a domain connection fails (DNS resolution blocked), it counts as blocked. Your overall score is the percentage of domains blocked.

## Requirements

- iOS 18+ / macOS 15+ (targeting 26+ when available)
- Xcode 16+
- Swift 6.0+

## Building

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Select your target (iOS or macOS)
4. Build and run

## Architecture

- **SwiftUI** multiplatform app
- **SwiftData** for test history persistence
- **@Observable** view model pattern
- **async/await** with `TaskGroup` for concurrent domain testing
- **URLSession** ephemeral sessions for clean, uncached connectivity checks

## License

GPLv3 - See [LICENSE](LICENSE) for details.
