import Testing
@testable import AdBlockReport

@Test func domainRegistryHasExpectedCount() {
    #expect(DomainRegistry.allDomains.count >= 130)
}

@Test func allCategoriesHaveDomains() {
    for category in TestCategory.allCases {
        let domains = DomainRegistry.domains(for: category)
        #expect(!domains.isEmpty, "Category \(category.rawValue) should have domains")
    }
}

@Test func domainsHaveValidHostnames() {
    for domain in DomainRegistry.allDomains {
        #expect(!domain.hostname.isEmpty)
        #expect(domain.hostname.contains("."), "\(domain.hostname) should contain a dot")
        #expect(!domain.hostname.hasPrefix("https://"), "\(domain.hostname) should not include scheme")
    }
}

@Test func providersGroupCorrectly() {
    let providers = DomainRegistry.providers
    #expect(providers.count >= 20, "Should have at least 20 providers")
    for (name, domains) in providers {
        #expect(!name.isEmpty)
        #expect(!domains.isEmpty)
    }
}
