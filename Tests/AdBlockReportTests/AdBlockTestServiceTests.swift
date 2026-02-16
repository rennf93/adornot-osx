import Testing
import Foundation
@testable import AdBlockReport

@Test func serviceClassifiesSuccessAsNotBlocked() async {
    let mock = MockURLSession()
    mock.setSuccess(for: "test.example.com")
    let service = AdBlockTestService(session: mock)

    let domain = TestDomain(hostname: "test.example.com", provider: "T", category: .ads)
    let results = await service.runTests(domains: [domain]) { _ in }

    #expect(results.count == 1)
    #expect(results[0].isBlocked == false)
    #expect(results[0].responseTimeMs != nil)
}

@Test func serviceClassifiesDNSFailureAsBlocked() async {
    let mock = MockURLSession()
    mock.setFailure(for: "blocked.example.com", error: .cannotFindHost)
    let service = AdBlockTestService(session: mock)

    let domain = TestDomain(hostname: "blocked.example.com", provider: "T", category: .ads)
    let results = await service.runTests(domains: [domain]) { _ in }

    #expect(results.count == 1)
    #expect(results[0].isBlocked == true)
}

@Test func serviceClassifiesTimeoutAsBlocked() async {
    let mock = MockURLSession()
    mock.setFailure(for: "slow.example.com", error: .timedOut)
    let service = AdBlockTestService(session: mock)

    let domain = TestDomain(hostname: "slow.example.com", provider: "T", category: .analytics)
    let results = await service.runTests(domains: [domain]) { _ in }

    #expect(results[0].isBlocked == true)
}

@Test func serviceClassifiesCannotConnectAsBlocked() async {
    let mock = MockURLSession()
    mock.setFailure(for: "refused.example.com", error: .cannotConnectToHost)
    let service = AdBlockTestService(session: mock)

    let domain = TestDomain(hostname: "refused.example.com", provider: "T", category: .mix)
    let results = await service.runTests(domains: [domain]) { _ in }

    #expect(results[0].isBlocked == true)
}

@Test func serviceClassifiesNotConnectedAsNotBlocked() async {
    let mock = MockURLSession()
    mock.setFailure(for: "offline.example.com", error: .notConnectedToInternet)
    let service = AdBlockTestService(session: mock)

    let domain = TestDomain(hostname: "offline.example.com", provider: "T", category: .oems)
    let results = await service.runTests(domains: [domain]) { _ in }

    // No internet should NOT count as blocked (avoids false positives)
    #expect(results[0].isBlocked == false)
}

@Test func serviceClassifiesCertErrorAsNotBlocked() async {
    let mock = MockURLSession()
    mock.setFailure(for: "cert.example.com", error: .serverCertificateUntrusted)
    let service = AdBlockTestService(session: mock)

    let domain = TestDomain(hostname: "cert.example.com", provider: "T", category: .socialTrackers)
    let results = await service.runTests(domains: [domain]) { _ in }

    // Cert error means DNS resolved, so not blocked
    #expect(results[0].isBlocked == false)
}

@Test func serviceReportsProgressCorrectly() async {
    let mock = MockURLSession()
    let domains = (0..<3).map { i -> TestDomain in
        let hostname = "d\(i).example.com"
        mock.setSuccess(for: hostname)
        return TestDomain(hostname: hostname, provider: "T", category: .ads)
    }
    let service = AdBlockTestService(session: mock)

    var progressUpdates: [Int] = []
    let results = await service.runTests(domains: domains) { progress in
        progressUpdates.append(progress.completed)
    }

    #expect(results.count == 3)
    #expect(progressUpdates.count == 3)
    #expect(progressUpdates.contains(3))
}

@Test func serviceHandlesMultipleDomainsConcurrently() async {
    let mock = MockURLSession()
    mock.setSuccess(for: "open1.com")
    mock.setSuccess(for: "open2.com")
    mock.setFailure(for: "blocked1.com", error: .cannotFindHost)
    mock.setFailure(for: "blocked2.com", error: .dnsLookupFailed)

    let domains = [
        TestDomain(hostname: "open1.com", provider: "T", category: .ads),
        TestDomain(hostname: "open2.com", provider: "T", category: .ads),
        TestDomain(hostname: "blocked1.com", provider: "T", category: .ads),
        TestDomain(hostname: "blocked2.com", provider: "T", category: .ads),
    ]
    let service = AdBlockTestService(session: mock)
    let results = await service.runTests(domains: domains) { _ in }

    let blocked = results.filter(\.isBlocked).count
    let exposed = results.filter { !$0.isBlocked }.count
    #expect(blocked == 2)
    #expect(exposed == 2)
}
