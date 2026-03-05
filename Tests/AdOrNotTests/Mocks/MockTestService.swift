import Foundation
@testable import AdOrNot

actor MockTestService: AdOrNotTestServiceProtocol {
    var mockResults: [TestResult] = []

    func setResults(_ results: [TestResult]) {
        self.mockResults = results
    }

    func runTests(
        domains: [TestDomain],
        onProgress: @Sendable (AdOrNotTestService.TestProgress) -> Void
    ) async -> [TestResult] {
        for (i, result) in mockResults.enumerated() {
            onProgress(AdOrNotTestService.TestProgress(
                completed: i + 1,
                total: mockResults.count,
                latestResult: result
            ))
        }
        return mockResults
    }

    func cleanup() async {}
}
