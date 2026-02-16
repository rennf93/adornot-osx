import Testing
import Foundation
@testable import AdBlockReport

@Test func testReportScoreCalculation() {
    let domains = (0..<10).map { i in
        TestDomain(hostname: "d\(i).example.com", provider: "P", category: .ads)
    }
    let results = domains.enumerated().map { i, d in
        TestResult(domain: d, isBlocked: i < 7)
    }
    let report = TestReport(results: results, duration: 5.0, deviceName: "Test", osVersion: "iOS 26.0")

    #expect(report.totalDomains == 10)
    #expect(report.blockedDomains == 7)
    #expect(report.overallScore == 70.0)
}

@Test func testReportEmptyResults() {
    let report = TestReport(results: [], duration: 0, deviceName: "Test", osVersion: "iOS 26.0")
    #expect(report.totalDomains == 0)
    #expect(report.blockedDomains == 0)
    #expect(report.overallScore == 0)
}

@Test func testReportCategoryScores() {
    let adsDomains = (0..<4).map { TestDomain(hostname: "ad\($0).com", provider: "P", category: .ads) }
    let analyticsDomains = (0..<2).map { TestDomain(hostname: "a\($0).com", provider: "P", category: .analytics) }

    var results: [TestResult] = []
    for (i, d) in adsDomains.enumerated() {
        results.append(TestResult(domain: d, isBlocked: i < 3))
    }
    for (i, d) in analyticsDomains.enumerated() {
        results.append(TestResult(domain: d, isBlocked: i < 1))
    }

    let report = TestReport(results: results, duration: 2.0, deviceName: "Test", osVersion: "macOS 26.0")

    #expect(report.categoryScores["Ads"] == 75.0)
    #expect(report.categoryScores["Analytics"] == 50.0)
}

@Test func testReportResultsDataRoundTrip() throws {
    let domain = TestDomain(hostname: "rt.example.com", provider: "RT", category: .mix)
    let results = [
        TestResult(domain: domain, isBlocked: true),
        TestResult(domain: domain, isBlocked: false, responseTimeMs: 100),
    ]
    let report = TestReport(results: results, duration: 1.0, deviceName: "Dev", osVersion: "iOS 26.0")

    let decoded = report.results
    #expect(decoded.count == 2)
    #expect(decoded[0].isBlocked == true)
    #expect(decoded[1].isBlocked == false)
    #expect(decoded[1].responseTimeMs == 100)
}

@Test func testReportAllBlocked() {
    let domains = (0..<5).map { TestDomain(hostname: "b\($0).com", provider: "P", category: .errorTrackers) }
    let results = domains.map { TestResult(domain: $0, isBlocked: true) }
    let report = TestReport(results: results, duration: 1.0, deviceName: "T", osVersion: "iOS 26.0")
    #expect(report.overallScore == 100.0)
}

@Test func testReportNoneBlocked() {
    let domains = (0..<5).map { TestDomain(hostname: "n\($0).com", provider: "P", category: .socialTrackers) }
    let results = domains.map { TestResult(domain: $0, isBlocked: false, responseTimeMs: 50) }
    let report = TestReport(results: results, duration: 1.0, deviceName: "T", osVersion: "iOS 26.0")
    #expect(report.overallScore == 0.0)
}
