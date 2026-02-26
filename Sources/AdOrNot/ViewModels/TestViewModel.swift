import Foundation
import Network
import SwiftData
import Observation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@Observable
@MainActor
final class TestViewModel {

    // MARK: - State

    enum TestState: Equatable {
        case idle
        case running
        case completed
    }

    var state: TestState = .idle
    var progress: Double = 0.0
    var completedCount: Int = 0
    var totalCount: Int = 0
    var currentDomain: String = ""

    var results: [TestResult] = []
    var overallScore: Double = 0.0
    var categoryScores: [TestCategory: Double] = [:]
    var latestReport: TestReport?

    var elapsedTime: TimeInterval = 0
    var networkUnavailable = false

    // MARK: - Settings

    var selectedCategories: Set<TestCategory> = Set(TestCategory.standardCases)
    var requestTimeout: Double = 6
    var exportFormat: ExportFormat = .text
    var testMode: TestMode = .standard

    // MARK: - Pi-hole

    let pihole = PiholeTestOrchestrator()

    // MARK: - Private

    private let injectedTestService: (any AdOrNotTestServiceProtocol)?
    private var testTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private let networkMonitor: NWPathMonitor?

    // MARK: - Lifecycle

    init(
        testService: (any AdOrNotTestServiceProtocol)? = nil,
        useNetworkMonitor: Bool = true
    ) {
        self.injectedTestService = testService
        if useNetworkMonitor {
            let monitor = NWPathMonitor()
            self.networkMonitor = monitor
            monitor.pathUpdateHandler = { [weak self] path in
                Task { @MainActor [weak self] in
                    self?.networkUnavailable = path.status != .satisfied
                }
            }
            monitor.start(queue: DispatchQueue(label: "com.adornot.network-monitor"))
        } else {
            self.networkMonitor = nil
        }
    }

    deinit {
        networkMonitor?.cancel()
    }

    // MARK: - Computed

    var domainsToTest: [TestDomain] {
        DomainRegistry.allDomains.filter { selectedCategories.contains($0.category) }
    }

    var resultsByCategory: [(category: TestCategory, results: [TestResult])] {
        let grouped = Dictionary(grouping: results, by: { $0.domain.category })
        return TestCategory.allCases.compactMap { category in
            guard let catResults = grouped[category], !catResults.isEmpty else { return nil }
            return (category: category, results: catResults)
        }
    }

    struct BlocklistBreakdownItem: Identifiable {
        let name: String
        let blocked: Int
        let total: Int
        var score: Double { total > 0 ? Double(blocked) / Double(total) * 100 : 0 }
        var id: String { name }
    }

    var blocklistBreakdownData: [BlocklistBreakdownItem] {
        let piholeResults = results.filter { $0.domain.category == .piholeBlocklists }
        let byList = Dictionary(grouping: piholeResults, by: { $0.domain.provider })
        return byList.map { name, listResults in
            BlocklistBreakdownItem(
                name: name,
                blocked: listResults.filter(\.isBlocked).count,
                total: listResults.count
            )
        }
        .sorted { $0.score > $1.score }
    }

    // MARK: - Actions

    func startTest(modelContext: ModelContext) {
        guard state != .running else { return }
        guard !networkUnavailable else { return }

        pihole.piholeError = nil
        let domains = domainsToTest
        state = .running
        elapsedTime = 0
        completedCount = 0
        progress = 0
        results = []

        if testMode == .pihole && injectedTestService == nil {
            startPiholeTest(modelContext: modelContext)
        } else {
            startStandardTest(domains: domains, modelContext: modelContext, mode: testMode)
        }
    }

    private func startStandardTest(domains: [TestDomain], modelContext: ModelContext, mode: TestMode) {
        totalCount = domains.count
        startTimer()

        testTask = Task { [weak self] in
            guard let self else { return }
            let startTime = Date()
            let testService = self.injectedTestService ?? AdOrNotTestService(requestTimeout: self.requestTimeout)

            let testResults = await testService.runTests(
                domains: domains
            ) { [weak self] progress in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.completedCount = progress.completed
                    self.progress = Double(progress.completed) / Double(progress.total)
                    self.currentDomain = progress.latestResult.domain.hostname
                }
            }

            guard !Task.isCancelled else { return }

            self.timerTask?.cancel()
            self.results = testResults
            self.calculateScores()

            let duration = Date().timeIntervalSince(startTime)
            let report = TestReport(
                results: testResults,
                duration: duration,
                deviceName: self.deviceName,
                osVersion: self.osVersionString,
                testMode: mode
            )
            modelContext.insert(report)
            try? modelContext.save()
            self.latestReport = report

            self.state = .completed
        }
    }

    private func startPiholeTest(modelContext: ModelContext) {
        totalCount = 0
        startTimer()

        testTask = Task { [weak self] in
            guard let self else { return }

            guard let blocklistDomains = await self.pihole.fetchDomains(requestTimeout: self.requestTimeout) else {
                self.timerTask?.cancel()
                self.state = .idle
                return
            }

            guard !Task.isCancelled else { return }

            let allDomains = self.domainsToTest + blocklistDomains
            self.totalCount = allDomains.count

            self.startStandardTest(domains: allDomains, modelContext: modelContext, mode: .pihole)
        }
    }

    func cancelTest() {
        testTask?.cancel()
        timerTask?.cancel()
        state = .idle
    }

    func reset() {
        cancelTest()
        results = []
        overallScore = 0
        categoryScores = [:]
        progress = 0
        completedCount = 0
        currentDomain = ""
        latestReport = nil
        state = .idle
    }

    // MARK: - Private Helpers

    private func startTimer() {
        timerTask = Task { [weak self] in
            let start = Date()
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                await MainActor.run { self?.elapsedTime = Date().timeIntervalSince(start) }
            }
        }
    }

    private func calculateScores() {
        let scores = ScoreCalculator.calculate(from: results)
        overallScore = scores.overall
        categoryScores = scores.byCategory
    }

    private var deviceName: String {
        #if canImport(UIKit)
        UIDevice.current.name
        #else
        Host.current().localizedName ?? "Mac"
        #endif
    }

    private var osVersionString: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        #if os(iOS)
        return "iOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #else
        return "macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #endif
    }
}
