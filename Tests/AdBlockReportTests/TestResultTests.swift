import Testing
import Foundation
@testable import AdBlockReport

@Test func testResultCodableRoundTrip() throws {
    let domain = TestDomain(hostname: "example.com", provider: "Test", category: .ads)
    let original = TestResult(domain: domain, isBlocked: true, responseTimeMs: 123.4, errorDescription: "timeout")

    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(TestResult.self, from: data)

    #expect(decoded.domain.hostname == original.domain.hostname)
    #expect(decoded.domain.provider == original.domain.provider)
    #expect(decoded.domain.category == original.domain.category)
    #expect(decoded.isBlocked == original.isBlocked)
    #expect(decoded.responseTimeMs == original.responseTimeMs)
    #expect(decoded.errorDescription == original.errorDescription)
}

@Test func testResultBlockedNoResponseTime() {
    let domain = TestDomain(hostname: "blocked.com", provider: "P", category: .analytics)
    let result = TestResult(domain: domain, isBlocked: true)
    #expect(result.isBlocked)
    #expect(result.responseTimeMs == nil)
    #expect(result.errorDescription == nil)
}

@Test func testResultExposedWithResponseTime() {
    let domain = TestDomain(hostname: "open.com", provider: "P", category: .mix)
    let result = TestResult(domain: domain, isBlocked: false, responseTimeMs: 250.0)
    #expect(!result.isBlocked)
    #expect(result.responseTimeMs == 250.0)
}

@Test func testDomainCodableRoundTrip() throws {
    let original = TestDomain(hostname: "test.example.com", provider: "Acme", category: .oems)
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(TestDomain.self, from: data)

    #expect(decoded.hostname == original.hostname)
    #expect(decoded.provider == original.provider)
    #expect(decoded.category == original.category)
}

@Test func testCategoryCodableRoundTrip() throws {
    for category in TestCategory.allCases {
        let data = try JSONEncoder().encode(category)
        let decoded = try JSONDecoder().decode(TestCategory.self, from: data)
        #expect(decoded == category)
    }
}

@Test func testCategoryHasSystemImage() {
    for category in TestCategory.allCases {
        #expect(!category.systemImage.isEmpty, "\(category.rawValue) should have a system image")
    }
}

@Test func testCategoryHasDescription() {
    for category in TestCategory.allCases {
        #expect(!category.description.isEmpty, "\(category.rawValue) should have a description")
    }
}
