import Testing
import Foundation
@testable import AdOrNot

@Test func scoreCalculatorEmptyResults() {
    let scores = ScoreCalculator.calculate(from: [])
    #expect(scores.overall == 0)
    #expect(scores.byCategory.isEmpty)
}

@Test func scoreCalculatorAllBlocked() {
    let domains = (0..<5).map { TestDomain(hostname: "d\($0).com", provider: "P", category: .ads) }
    let results = domains.map { TestResult(domain: $0, isBlocked: true) }
    let scores = ScoreCalculator.calculate(from: results)
    #expect(scores.overall == 100.0)
    #expect(scores.byCategory[.ads] == 100.0)
}

@Test func scoreCalculatorNoneBlocked() {
    let domains = (0..<5).map { TestDomain(hostname: "d\($0).com", provider: "P", category: .analytics) }
    let results = domains.map { TestResult(domain: $0, isBlocked: false) }
    let scores = ScoreCalculator.calculate(from: results)
    #expect(scores.overall == 0.0)
    #expect(scores.byCategory[.analytics] == 0.0)
}

@Test func scoreCalculatorMixedCategories() {
    let results = [
        TestResult(domain: TestDomain(hostname: "a1.com", provider: "P", category: .ads), isBlocked: true),
        TestResult(domain: TestDomain(hostname: "a2.com", provider: "P", category: .ads), isBlocked: false),
        TestResult(domain: TestDomain(hostname: "b1.com", provider: "P", category: .analytics), isBlocked: true),
        TestResult(domain: TestDomain(hostname: "b2.com", provider: "P", category: .analytics), isBlocked: true),
    ]
    let scores = ScoreCalculator.calculate(from: results)
    #expect(scores.overall == 75.0)
    #expect(scores.byCategory[.ads] == 50.0)
    #expect(scores.byCategory[.analytics] == 100.0)
}

@Test func scoreCalculatorByCategoryRawValueMapping() {
    let results = [
        TestResult(domain: TestDomain(hostname: "a.com", provider: "P", category: .ads), isBlocked: true),
        TestResult(domain: TestDomain(hostname: "b.com", provider: "P", category: .oems), isBlocked: false),
    ]
    let scores = ScoreCalculator.calculate(from: results)
    let rawValue = scores.byCategoryRawValue
    #expect(rawValue["Ads"] == 100.0)
    #expect(rawValue["OEMs"] == 0.0)
    #expect(rawValue.count == 2)
}
