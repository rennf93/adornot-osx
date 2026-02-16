import SwiftUI
import SwiftData

// MARK: - Sample Data for Previews

enum PreviewData {

    static let sampleDomains: [TestDomain] = [
        TestDomain(hostname: "pagead2.googlesyndication.com", provider: "Google Ads", category: .ads),
        TestDomain(hostname: "ad.doubleclick.net", provider: "DoubleClick", category: .ads),
        TestDomain(hostname: "adservice.google.com", provider: "Google Ads", category: .ads),
        TestDomain(hostname: "analytics.google.com", provider: "Google Analytics", category: .analytics),
        TestDomain(hostname: "script.hotjar.com", provider: "Hotjar", category: .analytics),
        TestDomain(hostname: "notify.bugsnag.com", provider: "Bugsnag", category: .errorTrackers),
        TestDomain(hostname: "pixel.facebook.com", provider: "Facebook", category: .socialTrackers),
        TestDomain(hostname: "ads.linkedin.com", provider: "LinkedIn", category: .socialTrackers),
        TestDomain(hostname: "ads.yahoo.com", provider: "Yahoo", category: .mix),
        TestDomain(hostname: "api.ad.xiaomi.com", provider: "Xiaomi", category: .oems),
    ]

    static let sampleResults: [TestResult] = sampleDomains.enumerated().map { index, domain in
        let blocked = index % 3 != 0 // ~67% blocked
        return TestResult(
            domain: domain,
            isBlocked: blocked,
            responseTimeMs: blocked ? nil : Double.random(in: 50...400)
        )
    }

    static let sampleAdsResults: [TestResult] = [
        TestResult(domain: sampleDomains[0], isBlocked: true),
        TestResult(domain: sampleDomains[1], isBlocked: true),
        TestResult(domain: sampleDomains[2], isBlocked: false, responseTimeMs: 142),
    ]

    @MainActor
    static func makeCompletedViewModel() -> TestViewModel {
        let vm = TestViewModel()
        vm.results = sampleResults
        vm.overallScore = 70
        vm.state = .completed
        vm.categoryScores = [
            .ads: 67,
            .analytics: 100,
            .errorTrackers: 100,
            .socialTrackers: 50,
            .mix: 100,
            .oems: 0,
        ]
        return vm
    }

    @MainActor
    static func makeRunningViewModel() -> TestViewModel {
        let vm = TestViewModel()
        vm.state = .running
        vm.progress = 0.67
        vm.completedCount = 88
        vm.totalCount = 131
        vm.currentDomain = "ads.linkedin.com"
        vm.elapsedTime = 24.5
        return vm
    }

    @MainActor
    static func makeIdleViewModel() -> TestViewModel {
        TestViewModel()
    }
}

// MARK: - SwiftData Preview Container

extension ModelContainer {
    @MainActor
    static var preview: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: TestReport.self, configurations: config)
        return container
    }
}
