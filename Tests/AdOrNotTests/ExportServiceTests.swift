import Testing
import Foundation
@testable import AdOrNot

@Test func exportTextReportContainsHeader() {
    let report = makeTestReport()
    let text = ExportService.generateTextReport(report)
    #expect(text.contains("AdOrNot"))
    #expect(text.contains("=============="))
}

@Test func exportTextReportContainsScore() {
    let report = makeTestReport()
    let text = ExportService.generateTextReport(report)
    let formattedScore = String(format: "%.0f", report.overallScore)
    #expect(text.contains("\(formattedScore)%"))
}

@Test func exportTextReportContainsDeviceInfo() {
    let report = makeTestReport()
    let text = ExportService.generateTextReport(report)
    #expect(text.contains("TestDevice"))
    #expect(text.contains("iOS 26.0.0"))
}

@Test func exportTextReportContainsCategoryBreakdown() {
    let report = makeTestReport()
    let text = ExportService.generateTextReport(report)
    #expect(text.contains("Category Breakdown"))
    #expect(text.contains("Ads"))
}

@Test func exportTextReportContainsBlockedAndExposed() {
    let report = makeTestReport()
    let text = ExportService.generateTextReport(report)
    #expect(text.contains("[BLOCKED]"))
    #expect(text.contains("[EXPOSED]"))
}

@Test func exportJSONIsValidJSON() throws {
    let report = makeTestReport()
    let data = try #require(ExportService.generateJSONData(report))
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(json != nil)
}

@Test func exportJSONContainsExpectedKeys() throws {
    let report = makeTestReport()
    let data = try #require(ExportService.generateJSONData(report))
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(json["overallScore"] != nil)
    #expect(json["device"] != nil)
    #expect(json["osVersion"] != nil)
    #expect(json["results"] != nil)
    #expect(json["categoryScores"] != nil)
}

@Test func exportJSONResultsMatchCount() throws {
    let report = makeTestReport()
    let data = try #require(ExportService.generateJSONData(report))
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    let results = try #require(json["results"] as? [[String: Any]])
    #expect(results.count == report.results.count)
}

private func makeTestReport() -> TestReport {
    let domains = [
        TestDomain(hostname: "ad1.example.com", provider: "P1", category: .ads),
        TestDomain(hostname: "an1.example.com", provider: "P2", category: .analytics),
        TestDomain(hostname: "ad2.example.com", provider: "P1", category: .ads),
    ]
    let results = [
        TestResult(domain: domains[0], isBlocked: true),
        TestResult(domain: domains[1], isBlocked: false, responseTimeMs: 200),
        TestResult(domain: domains[2], isBlocked: true),
    ]
    return TestReport(results: results, duration: 3.5, deviceName: "TestDevice", osVersion: "iOS 26.0.0")
}
