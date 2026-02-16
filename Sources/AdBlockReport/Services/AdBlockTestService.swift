import Foundation

actor AdBlockTestService {

    struct TestProgress: Sendable {
        let completed: Int
        let total: Int
        let latestResult: TestResult
    }

    private let session: URLSession
    private let maxConcurrency = 8

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 6
        config.timeoutIntervalForResource = 10
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never
        config.urlCache = nil
        self.session = URLSession(configuration: config)
    }

    func runTests(
        domains: [TestDomain],
        onProgress: @Sendable (TestProgress) -> Void
    ) async -> [TestResult] {
        var allResults: [TestResult] = []
        let total = domains.count
        var completed = 0

        for batch in domains.chunked(into: maxConcurrency) {
            await withTaskGroup(of: TestResult.self) { group in
                for domain in batch {
                    group.addTask {
                        await self.testDomain(domain)
                    }
                }
                for await result in group {
                    allResults.append(result)
                    completed += 1
                    onProgress(TestProgress(
                        completed: completed,
                        total: total,
                        latestResult: result
                    ))
                }
            }
        }

        return allResults
    }

    private func testDomain(_ domain: TestDomain) async -> TestResult {
        let startTime = CFAbsoluteTimeGetCurrent()

        guard let url = URL(string: "https://\(domain.hostname)/") else {
            return TestResult(
                domain: domain,
                isBlocked: true,
                errorDescription: "Invalid URL"
            )
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        do {
            let (_, response) = try await session.data(for: request)
            let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

            if response is HTTPURLResponse {
                return TestResult(domain: domain, isBlocked: false, responseTimeMs: elapsed)
            }

            return TestResult(domain: domain, isBlocked: false, responseTimeMs: elapsed)
        } catch {
            let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            let urlError = error as? URLError

            // These error codes indicate DNS/connection-level blocking
            let blockingErrors: Set<URLError.Code> = [
                .timedOut,
                .cannotFindHost,
                .cannotConnectToHost,
                .networkConnectionLost,
                .dnsLookupFailed,
                .notConnectedToInternet,
                .secureConnectionFailed,
            ]

            let isBlocked: Bool
            if let code = urlError?.code, blockingErrors.contains(code) {
                isBlocked = true
            } else if urlError?.code == .serverCertificateUntrusted {
                // Certificate error means DNS resolved successfully — not blocked
                isBlocked = false
            } else {
                isBlocked = true
            }

            return TestResult(
                domain: domain,
                isBlocked: isBlocked,
                responseTimeMs: elapsed,
                errorDescription: error.localizedDescription
            )
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
