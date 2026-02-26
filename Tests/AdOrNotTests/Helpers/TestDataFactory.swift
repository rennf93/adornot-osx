import Foundation
@testable import AdOrNot

enum TestDataFactory {

    static func makeDomains(
        count: Int = 3,
        category: TestCategory = .ads,
        provider: String = "TestProvider"
    ) -> [TestDomain] {
        (0..<count).map {
            TestDomain(hostname: "d\($0).\(category.rawValue.lowercased()).example.com", provider: provider, category: category)
        }
    }

    static func makeResults(
        domains: [TestDomain]? = nil,
        blockedCount: Int? = nil
    ) -> [TestResult] {
        let domains = domains ?? makeDomains()
        let blocked = blockedCount ?? domains.count
        return domains.enumerated().map { index, domain in
            TestResult(domain: domain, isBlocked: index < blocked)
        }
    }

    static func makeReport(
        results: [TestResult]? = nil,
        duration: Double = 3.5,
        deviceName: String = "TestDevice",
        osVersion: String = "iOS 26.0.0",
        testMode: TestMode = .standard
    ) -> TestReport {
        let results = results ?? makeResults()
        return TestReport(
            results: results,
            duration: duration,
            deviceName: deviceName,
            osVersion: osVersion,
            testMode: testMode
        )
    }
}
