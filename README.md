<p align="center">
  <img src="logos/final_256.png" alt="AdOrNot Logo" width="128" height="128">
</p>

<h1 align="center">AdOrNot</h1>

<p align="center">
  <strong>Test the effectiveness of your DNS-level ad blocker</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0">
  <img src="https://img.shields.io/badge/iOS-18%2B-blue.svg" alt="iOS 18+">
  <img src="https://img.shields.io/badge/macOS-15%2B-blue.svg" alt="macOS 15+">
  <img src="https://img.shields.io/badge/License-GPLv3-green.svg" alt="GPLv3">
</p>

---

## What It Does

AdOrNot tests whether your DNS-level ad blocker — Pi-hole, NextDNS, AdGuard, or any system-level content blocker — is effectively blocking known advertising, analytics, and tracking domains.

The app sends HTTPS HEAD requests to 128 well-known ad and tracking endpoints across 6 categories. If a domain's DNS lookup is blocked by your filter, the connection fails and the domain counts as blocked. Your overall score is the percentage of domains blocked.

AdOrNot is fully native to iOS and macOS, has zero external dependencies, and collects no data whatsoever. All tests run locally on your device.

## Features

- **128 curated domains** across 30 providers and 6 categories
- **Per-category and overall scores** with animated gauge visualizations
- **Concurrent testing** — 8 domains tested simultaneously for fast results
- **Test history** — all results persist locally via SwiftData
- **Export results** as formatted text or JSON
- **Native iOS and macOS** with adaptive layouts (TabView / NavigationSplitView)
- **Glass morphism design** with animated mesh backgrounds
- **Configurable timeout** for slow or strict networks
- **Category filtering** — test only the categories you care about
- **Zero dependencies** — pure Swift and Apple frameworks only
- **Open source** under GPLv3

<!-- ## Screenshots -->
<!-- TODO: Add screenshots of iOS and macOS -->

## Domain Categories

| Category | Icon | Providers | Domains |
|----------|------|-----------|---------|
| **Ads** | megaphone.fill | Amazon, Google Ads, DoubleClick, AdColony, Media.net | 19 |
| **Analytics** | chart.bar.fill | Google Analytics, Hotjar, MouseFlow, FreshWorks, LuckyOrange, WordPress Stats | 30 |
| **Error Trackers** | ladybug.fill | Bugsnag, Sentry | 6 |
| **Social Trackers** | person.2.fill | Facebook, Twitter, LinkedIn, Pinterest, Reddit, YouTube, TikTok | 19 |
| **Mix** | square.grid.2x2.fill | Yahoo, Yandex, Unity | 19 |
| **OEMs** | cpu.fill | Realme, Xiaomi, Oppo, Huawei, OnePlus, Samsung, Apple | 35 |

## How It Works

1. **Select categories** — Choose which domain categories to test (all 6 enabled by default)
2. **Send HEAD requests** — The app sends an HTTPS HEAD request to each domain using an ephemeral URL session (no cookies, no cache)
3. **Detect blocking** — If DNS resolution fails (`.cannotFindHost`, `.dnsLookupFailed`, `.timedOut`, etc.), the domain is counted as blocked
4. **Avoid false positives** — If the device is offline (`.notConnectedToInternet`) or the server has a certificate error (`.serverCertificateUntrusted`), the domain is marked as NOT blocked to prevent misleading results
5. **Calculate scores** — Blocking percentage is computed per-category and overall
6. **Save results** — Each test run is persisted locally via SwiftData for historical comparison

## Score Interpretation

| Score | Level | Meaning |
|-------|-------|---------|
| **60%+** | Strong Protection | Your ad blocker is catching most known trackers |
| **30–59%** | Moderate Protection | Some domains are getting through — consider tightening your filter lists |
| **< 30%** | Weak Protection | Most domains are reachable — your blocker may not be active or properly configured |

## Requirements

- iOS 18+ or macOS 15+
- Xcode 16+ (for building from source)
- Swift 6.0+
- Active network connection

## Building

### From Xcode

1. Clone the repository
2. Open `AdOrNot.xcodeproj`
3. Select your target (iOS Simulator, iPhone, or My Mac)
4. Build and run (Cmd+R)
5. Run tests (Cmd+U)

### From Command Line

```bash
swift build   # Build the project
swift test    # Run all tests
```

## Architecture

- **SwiftUI** multiplatform app (iOS + macOS from a single codebase)
- **MVVM + actor services** — `@Observable` view model, actor-isolated test service
- **SwiftData** for test history persistence
- **Structured concurrency** — `TaskGroup` with batched execution (8 concurrent requests)
- **Dependency injection** via protocols for full testability
- **Zero external dependencies**

For detailed architecture documentation, code patterns, and implementation guides, see [CLAUDE.md](CLAUDE.md).

## Privacy

AdOrNot is designed with privacy as a core principle:

- **No data collection** — No analytics, no telemetry, no crash reporting
- **All tests run locally** — HEAD requests go directly from your device to the test domains
- **App Sandbox** — Only the `network.client` entitlement is used (required for connectivity tests)
- **No tracking** — The app does not phone home or communicate with any backend

## Contributing

1. Fork the repository and create a feature branch
2. Follow existing code patterns and conventions
3. Use **Swift Testing** for all tests (`@Test`, `#expect`) — not XCTest
4. Use the `Theme` system for all UI styling
5. Run `swift test` and ensure all tests pass
6. See [CLAUDE.md](CLAUDE.md) for detailed coding guidelines and gotchas

## License

This project is licensed under the GNU General Public License v3.0 — see the [LICENSE](LICENSE) file for details.
