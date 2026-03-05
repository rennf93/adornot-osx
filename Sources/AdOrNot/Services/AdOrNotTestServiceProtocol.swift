import Foundation

protocol AdOrNotTestServiceProtocol: Sendable {
    func runTests(
        domains: [TestDomain],
        onProgress: @Sendable (AdOrNotTestService.TestProgress) -> Void
    ) async -> [TestResult]
    func cleanup() async
}

extension AdOrNotTestService: AdOrNotTestServiceProtocol {}
