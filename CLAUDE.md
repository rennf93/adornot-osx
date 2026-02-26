# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AdOrNot is a native iOS 18+ / macOS 15+ SwiftUI app that tests DNS-level ad blocker effectiveness. It performs HTTPS HEAD requests to 128 curated advertising, analytics, tracking, and OEM telemetry domains across 6 categories, then scores how many your blocker stops. Zero external dependencies. Built with Swift 6.0 / Xcode 16+.

## Build & Test Commands

```bash
swift build            # Build from command line
swift test             # Run all tests
open AdOrNot.xcodeproj # Open in Xcode (Cmd+R to run, Cmd+U to test)
```

Tests use **Swift Testing** (`import Testing`, `@Test`, `#expect`). Never use XCTest.

## Architecture Overview

**MVVM + Actor Services** with SwiftUI multiplatform. 33 source files, 14 test files.

### File Map

**`App/`** — Entry point
- `AdOrNotApp.swift` — `@main`, creates SwiftData `ModelContainer` for `TestReport`, launches `LaunchView`
- `AppVersion.swift` — Bundle version string helper

**`Models/`** — Data types
- `TestCategory.swift` — Enum with 6 cases (`ads`, `analytics`, `errorTrackers`, `socialTrackers`, `mix`, `oems`), each with `rawValue`, `systemImage`, `description`
- `TestDomain.swift` — `hostname` + `provider` + `category`
- `TestResult.swift` — `domain` + `isBlocked` + `responseTimeMs` + `errorDescription`
- `TestReport.swift` — `@Model` (SwiftData). Uses `ScoreCalculator` for score computation. Stores `resultsData` as JSON-encoded `Data` blob and `categoryScores` as `[String: Double]` with `TestCategory.rawValue` keys
- `DomainRegistry.swift` — 128 curated domains across 30 providers, organized by `// MARK:` sections per category
- `ExportFormat.swift` — `.text` / `.json` enum

**`Services/`** — Business logic
- `AdOrNotTestService.swift` — Actor. Concurrent HEAD request testing. Also contains `Array.chunked(into:)` extension (lines 119-125)
- `AdOrNotTestServiceProtocol.swift` — Protocol for DI, `AdOrNotTestService` conforms via extension
- `URLSessionProtocol.swift` — Protocol wrapping `data(for:)`, `URLSession` conforms via extension
- `ExportService.swift` — Static methods for text and JSON report generation
- `ScoreCalculator.swift` — Single source of truth for score computation. `Scores` struct with `overall`, `byCategory`, `byCategoryRawValue`
- `PiholeTestService.swift` — Actor. Pi-hole v6 API client: auth, blocklist URL fetching, hosts file parsing
- `PiholeTestOrchestrator.swift` — `@Observable @MainActor`. Pi-hole config (host, password), connection testing, domain fetching. Owned by `TestViewModel.pihole`

**`ViewModels/`** — UI state
- `TestViewModel.swift` — `@Observable @MainActor`. Three states: `.idle`, `.running`, `.completed`. Manages test execution via `ScoreCalculator`, category filtering, `NWPathMonitor` for connectivity, configurable timeout. Pi-hole logic delegated to `pihole: PiholeTestOrchestrator`

**`Views/`** — 16 SwiftUI views
- `LaunchView.swift` — Root view (not ContentView). Animated splash for 1.5s, then transitions to `ContentView`
- `ContentView.swift` — `NavigationSplitView` on macOS (min 720x520) / `TabView` on iOS. Three tabs: Test, History, Settings
- `HomeView.swift` — Start test / show results hub
- `TestingView.swift` — Progress during test execution
- `ResultsView.swift` — Overall + per-category score display. Blocklist breakdown uses `viewModel.blocklistBreakdownData`
- `ScoreGaugeView.swift` — Animated circular gauge
- `CategoryResultView.swift` — Per-category domain results
- `DomainResultRow.swift` — Single domain blocked/exposed row
- `HistoryView.swift` — SwiftData-backed test history list
- `HistoryDetailView.swift` — Detail view for a past test report
- `SettingsView.swift` — Timeout, category selection, data management, about
- `PiholeSettingsSection.swift` — Pi-hole host/password/connection test UI (extracted from SettingsView)
- `AboutView.swift` — About detail sheet (extracted from SettingsView)
- `SharedComponents.swift` — `SectionHeader`, `WarningBanner`, `StyledDivider` reusable components
- `ShareSheet.swift` — `UIActivityViewController` (iOS) / AppKit copy-to-clipboard modal (macOS)
- `PreviewHelpers.swift` — `PreviewData` factories + `ModelContainer.preview` (in-memory)

**Root files**
- `Theme.swift` — Centralized design system: colors, gradients, spacing, radii, shadows, animation durations (`animationQuick`, `animationDefault`, `animationGaugeFill`), `GlassCard` modifier, `GradientButtonStyle`, `SecondaryButtonStyle`, `AnimatedMeshBackground`, `StatCard`, responsive grid helpers
- `ScoreThreshold.swift` — `good = 60`, `moderate = 30`, with `color(for:)` and `label(for:)` helpers

## Blocking Detection Algorithm

This is the most critical domain logic. Located in `AdOrNotTestService.swift:61-116`.

**Request:** HTTPS HEAD to `https://{hostname}/` via ephemeral `URLSession` (no cookies, no cache, configurable timeout defaulting to 6s, resource timeout = request timeout + 4s).

**Classification rules (priority order):**

1. **Any HTTP response** (any status code) → **NOT blocked** — DNS resolved, connection succeeded
2. **`.notConnectedToInternet`** → **NOT blocked** — Avoids false positives when device is offline
3. **`.serverCertificateUntrusted`** → **NOT blocked** — DNS resolved successfully (cert errors ≠ blocking)
4. **Blocking error set** → **BLOCKED**:
   - `.timedOut`, `.cannotFindHost`, `.cannotConnectToHost`
   - `.networkConnectionLost`, `.dnsLookupFailed`, `.secureConnectionFailed`
5. **Any other error** → **BLOCKED** (default fallback)

**Warning:** Changing this logic affects every test result across the app.

## Score Calculation

`ScoreCalculator.calculate(from:)` is the single source of truth. Used by both `TestReport.init` (for persistence) and `TestViewModel.calculateScores()` (for live display). Returns a `Scores` struct with `overall: Double` and `byCategory: [TestCategory: Double]`. The `byCategoryRawValue` computed property converts to `[String: Double]` for SwiftData storage.

## Concurrency Model

- `AdOrNotTestService` is an **actor** — all mutable state is actor-isolated
- Domains are split into batches of 8 via `Array.chunked(into:)` (extension at bottom of `AdOrNotTestService.swift`)
- Each batch runs concurrently via `withTaskGroup` — all 8 requests fire simultaneously
- Batches execute **sequentially** — batch N+1 starts after batch N completes
- Progress callback fires per individual result (not per batch)
- `TestViewModel` receives progress updates on `@MainActor`

## Platform-Specific Patterns

Every `#if` branch in the codebase:

| File | macOS | iOS |
|------|-------|-----|
| `ContentView.swift` | `NavigationSplitView` (min 720x520) | `TabView` |
| `Theme.swift` | `Color(.windowBackgroundColor)` for `cardSurface` | `Color(.systemBackground)` |
| `TestViewModel.swift` | `Host.current().localizedName` for device name; `"macOS"` prefix | `UIDevice.current.name`; `"iOS"` prefix |
| `ShareSheet.swift` | AppKit: `NSPasteboard` copy-to-clipboard modal | UIKit: `UIActivityViewController` |

Conditional imports: `#if canImport(UIKit)` / `#if canImport(AppKit)` in `TestViewModel`, `ShareSheet`.
Platform check: `#if os(macOS)` / `#if os(iOS)` in `ContentView`, `Theme`, `TestViewModel`.

## SwiftData Persistence

- `TestReport` is the only `@Model` class
- `resultsData` stores `[TestResult]` as a JSON-encoded `Data` blob (SwiftData can't store custom array types directly)
- `categoryScores` uses `[String: Double]` with `TestCategory.rawValue` as keys (not `TestCategory` enum — SwiftData can't use enum keys in dictionaries)
- `ModelContainer` is created in `AdOrNotApp` for `TestReport.self`
- Preview container: `ModelContainer.preview` (static, `@MainActor`) uses `ModelConfiguration(isStoredInMemoryOnly: true)` in `PreviewHelpers.swift`

## Testing Patterns

**Framework:** Swift Testing (`import Testing`, `@Test`, `#expect`). 14 test files, 98 tests.

**Test files:** `AdOrNotTestServiceTests`, `ArrayChunkedTests`, `BlocklistRegistryTests`, `DomainRegistryTests`, `ExportServiceTests`, `KeychainHelperTests`, `PiholeTestServiceTests`, `ProviderRegistryTests`, `ScoreCalculatorTests`, `ScoreThresholdTests`, `TestModeTests`, `TestReportTests`, `TestResultTests`, `TestViewModelTests`

**Mocks** (`Tests/AdOrNotTests/Mocks/`):
- `MockTestService` — Actor conforming to `AdOrNotTestServiceProtocol`. Returns preconfigured results
- `MockURLSession` — Class (`@unchecked Sendable`) conforming to `URLSessionProtocol`. Supports per-hostname response configuration
- `PiholeMockURLSession` — Class (`@unchecked Sendable`) conforming to `URLSessionProtocol`. Mocks Pi-hole API auth, lists, and blocklist file downloads

**Test helpers** (`Tests/AdOrNotTests/Helpers/`):
- `TestDataFactory` — `makeDomains()`, `makeResults()`, `makeReport()` factory methods

**Dependency injection:**
- `TestViewModel(testService:useNetworkMonitor:false)` — Inject mock service, disable network monitor
- `AdOrNotTestService(session:)` — Inject mock URL session
- `PiholeTestService(baseURL:password:session:)` — Inject mock URL session

**Important:** ViewModel tests must be `@MainActor` since `TestViewModel` is `@MainActor`.

## Theme & Responsive Grid

**Colors:** `brandBlue`/`brandBlueLight`/`brandNavy`/`brandNavyDeep`/`brandIndigo`/`brandCyan`, `scoreGood`/`scoreModerate`/`scoreWeak`

**Spacing:** `spacingXS=4`, `spacingSM=8`, `spacingMD=16`, `spacingLG=24`, `spacingXL=32`, `spacingXXL=48`

**Corner radii:** `radiusSM=8`, `radiusMD=12`, `radiusLG=16`, `radiusXL=20`

**Animation durations:** `animationQuick=0.15`, `animationDefault=0.25`, `animationGaugeFill=1.2`

**Responsive grid pattern** (used in ResultsView, HistoryView, HomeView, SettingsView):
1. Track container width with `onGeometryChange`
2. Compute columns via `Theme.responsiveColumnCount(availableWidth:minColumns:idealItemWidth:)`
3. Build grid items via `Theme.flexibleColumns(count:spacing:)`
4. Render with `LazyVGrid`

**Reusable components:** `.glassCard()` modifier, `GradientButtonStyle`, `SecondaryButtonStyle`, `AnimatedMeshBackground`, `StatCard`, `SectionHeader`, `WarningBanner`, `StyledDivider`

## How to Add Domains

1. Open `Sources/AdOrNot/Models/DomainRegistry.swift`
2. Find the appropriate `// MARK:` section for the category
3. Add entries using `TestDomain(hostname:provider:category:)` — bare hostname only, no `https://` prefix, no trailing slash
4. `DomainRegistryTests` validates all hostnames contain no scheme or path characters
5. If adding a new provider, it will automatically appear in `DomainRegistry.providers`

## Key Gotchas

- **Swift Testing only** — never use XCTest (`import XCTest`, `XCTAssert*`, etc.)
- **`Array.chunked(into:)`** lives in `AdOrNotTestService.swift` as an extension, not in a separate utility file
- **Ephemeral URLSession is intentional** — never add caching, cookies, or persistent storage to the test session
- **`swiftLanguageModes: [.v5]`** in `Package.swift` is intentional (Swift 6 toolchain, Swift 5 language mode)
- **`TestReport.categoryScores`** uses `String` keys (`TestCategory.rawValue`), not `TestCategory` enum keys
- **`.notConnectedToInternet` = NOT blocked** — this is an anti-false-positive measure, not a bug
- **`.serverCertificateUntrusted` = NOT blocked** — certificate errors prove DNS resolved
- **`@Observable` exclusively** — no `ObservableObject` or `@Published` anywhere in the codebase
- **`LaunchView` is the root view**, not `ContentView` — app flow: `AdOrNotApp` → `LaunchView` (1.5s splash) → `ContentView`
- **Preview helpers:** Use `PreviewData` factories for sample data and `.modelContainer(.preview)` for SwiftData previews
- **Entitlements:** App Sandbox + `com.apple.security.network.client` only — no other permissions
- **`ScoreThreshold.swift`** is at the `Sources/AdOrNot/` root level, not inside `Models/`
- **Pi-hole properties** live on `viewModel.pihole` (a `PiholeTestOrchestrator`), not directly on `TestViewModel`
- **`ScoreCalculator`** is the single source of truth for score computation — never duplicate score logic elsewhere
- **`SectionHeader`, `WarningBanner`, `StyledDivider`** in `SharedComponents.swift` — use these instead of inline implementations
- **Animation durations** — use `Theme.animationQuick/animationDefault/animationGaugeFill` instead of hardcoded values
