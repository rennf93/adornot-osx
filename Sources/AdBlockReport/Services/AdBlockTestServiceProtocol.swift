import Foundation

protocol AdBlockTestServiceProtocol: Sendable {
    func runTests(
        domains: [TestDomain],
        onProgress: @Sendable (AdBlockTestService.TestProgress) -> Void
    ) async -> [TestResult]
}

extension AdBlockTestService: AdBlockTestServiceProtocol {}
