import Testing
@testable import AdOrNot

struct ProviderRegistryTests {

    @Test("Every domain provider has a matching ProviderInfo entry")
    func allProvidersHaveInfo() {
        let providerNames = Set(DomainRegistry.allDomains.map(\.provider))
        for name in providerNames {
            let info = ProviderRegistry.info(for: name)
            #expect(info != nil, "Missing ProviderInfo for provider: \(name)")
        }
    }

    @Test("All provider URLs use HTTPS")
    func allURLsUseHTTPS() {
        for (_, info) in ProviderRegistry.all {
            #expect(
                info.websiteURL.scheme == "https",
                "\(info.name) URL is not HTTPS: \(info.websiteURL)"
            )
        }
    }

    @Test("All provider descriptions are non-empty")
    func allDescriptionsNonEmpty() {
        for (_, info) in ProviderRegistry.all {
            #expect(!info.description.isEmpty, "\(info.name) has empty description")
        }
    }

    @Test("Provider registry has correct count")
    func registryCount() {
        let providerNames = Set(DomainRegistry.allDomains.map(\.provider))
        #expect(ProviderRegistry.all.count == providerNames.count)
    }

    @Test("Provider IDs match their dictionary keys")
    func idsMatchKeys() {
        for (key, info) in ProviderRegistry.all {
            #expect(key == info.id, "Key '\(key)' doesn't match id '\(info.id)'")
        }
    }
}
