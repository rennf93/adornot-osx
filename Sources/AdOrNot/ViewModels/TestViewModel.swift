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
    var piholeHost: String = UserDefaults.standard.string(forKey: "piholeHost") ?? ""
    var piholeError: String?

    var isPiholeConfigured: Bool {
        !piholeHost.isEmpty && KeychainHelper.load(key: "piholePassword") != nil
    }

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

    // MARK: - Actions

    func startTest(modelContext: ModelContext) {
        guard state != .running else { return }
        guard !networkUnavailable else { return }

        piholeError = nil
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

        timerTask = Task { [weak self] in
            let start = Date()
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                await MainActor.run { self?.elapsedTime = Date().timeIntervalSince(start) }
            }
        }

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

        timerTask = Task { [weak self] in
            let start = Date()
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                await MainActor.run { self?.elapsedTime = Date().timeIntervalSince(start) }
            }
        }

        testTask = Task { [weak self] in
            guard let self else { return }
            let startTime = Date()

            // Phase 1: Fetch domains from Pi-hole blocklists
            let password = KeychainHelper.load(key: "piholePassword") ?? ""
            let piholeService = PiholeTestService(baseURL: self.piholeHost, password: password)
            let blocklistDomains = await piholeService.fetchBlocklistDomains()

            if blocklistDomains.isEmpty {
                let error = await piholeService.lastError
                self.piholeError = error ?? "No domains found in Pi-hole blocklists"
                self.timerTask?.cancel()
                self.state = .idle
                return
            }

            guard !Task.isCancelled else { return }

            // Combine standard curated domains + blocklist domains
            let standardDomains = self.domainsToTest
            let allDomains = standardDomains + blocklistDomains
            self.totalCount = allDomains.count

            // Phase 2: Test all domains with HEAD requests
            let testService = AdOrNotTestService(requestTimeout: self.requestTimeout)

            let testResults = await testService.runTests(
                domains: allDomains
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
                testMode: .pihole
            )
            modelContext.insert(report)
            try? modelContext.save()
            self.latestReport = report

            self.state = .completed
        }
    }

    func savePiholeHost(_ host: String) {
        piholeHost = host
        UserDefaults.standard.set(host, forKey: "piholeHost")
    }

    func testPiholeConnection() async -> Bool {
        let password = KeychainHelper.load(key: "piholePassword") ?? ""
        let service = PiholeTestService(baseURL: piholeHost, password: password)
        let success = await service.authenticate()
        if !success {
            piholeError = await service.lastError
        } else {
            piholeError = nil
        }
        return success
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

    private func calculateScores() {
        guard !results.isEmpty else { return }
        let blocked = results.filter(\.isBlocked).count
        overallScore = (Double(blocked) / Double(results.count)) * 100.0

        let grouped = Dictionary(grouping: results, by: { $0.domain.category })
        for (category, catResults) in grouped {
            let catBlocked = catResults.filter(\.isBlocked).count
            categoryScores[category] = (Double(catBlocked) / Double(catResults.count)) * 100.0
        }
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
