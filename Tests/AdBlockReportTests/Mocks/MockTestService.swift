import Foundation
@testable import AdBlockReport

actor MockTestService: AdBlockTestServiceProtocol {
    var mockResults: [TestResult] = []

    func setResults(_ results: [TestResult]) {
        self.mockResults = results
    }

    func runTests(
        domains: [TestDomain],
        onProgress: @Sendable (AdBlockTestService.TestProgress) -> Void
    ) async -> [TestResult] {
        for (i, result) in mockResults.enumerated() {
            onProgress(AdBlockTestService.TestProgress(
                completed: i + 1,
                total: mockResults.count,
                latestResult: result
            ))
        }
        return mockResults
    }
}
