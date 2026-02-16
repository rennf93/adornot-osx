import Foundation
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

    // MARK: - Settings

    var selectedCategories: Set<TestCategory> = Set(TestCategory.allCases)

    // MARK: - Private

    private let testService = AdBlockTestService()
    private var testTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?

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

    var scoreLevel: ScoreLevel {
        ScoreLevel(score: overallScore)
    }

    enum ScoreLevel {
        case good, moderate, poor

        init(score: Double) {
            if score >= 60 { self = .good }
            else if score >= 30 { self = .moderate }
            else { self = .poor }
        }
    }

    // MARK: - Actions

    func startTest(modelContext: ModelContext) {
        guard state != .running else { return }

        let domains = domainsToTest
        totalCount = domains.count
        completedCount = 0
        progress = 0
        results = []
        state = .running
        elapsedTime = 0

        timerTask = Task { [weak self] in
            let start = Date()
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                self?.elapsedTime = Date().timeIntervalSince(start)
            }
        }

        testTask = Task { [weak self] in
            guard let self else { return }
            let startTime = Date()

            let testResults = await testService.runTests(
                domains: domains
            ) { [weak self] progress in
                Task { @MainActor in
                    self?.completedCount = progress.completed
                    self?.progress = Double(progress.completed) / Double(progress.total)
                    self?.currentDomain = progress.latestResult.domain.hostname
                }
            }

            self.timerTask?.cancel()
            self.results = testResults
            self.calculateScores()

            let duration = Date().timeIntervalSince(startTime)
            let report = TestReport(
                results: testResults,
                duration: duration,
                deviceName: self.deviceName,
                osVersion: self.osVersionString
            )
            modelContext.insert(report)
            try? modelContext.save()
            self.latestReport = report

            self.state = .completed
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
