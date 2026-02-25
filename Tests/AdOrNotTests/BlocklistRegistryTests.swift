import Testing
@testable import AdOrNot

struct BlocklistRegistryTests {

    @Test("Registry has at least 10 entries")
    func minimumEntryCount() {
        #expect(BlocklistRegistry.allLists.count >= 10)
    }

    @Test("All blocklist IDs are unique")
    func uniqueIDs() {
        let ids = BlocklistRegistry.allLists.map(\.id)
        let uniqueIDs = Set(ids)
        #expect(ids.count == uniqueIDs.count, "Duplicate IDs found")
    }

    @Test("All blocklist URLs use HTTPS")
    func allURLsUseHTTPS() {
        for entry in BlocklistRegistry.allLists {
            #expect(
                entry.websiteURL.scheme == "https",
                "\(entry.name) URL is not HTTPS: \(entry.websiteURL)"
            )
        }
    }

    @Test("All categories have at least one list")
    func allCategoriesCovered() {
        for category in BlocklistEntry.Category.allCases {
            let lists = BlocklistRegistry.lists(for: category)
            #expect(!lists.isEmpty, "No blocklists for category: \(category.rawValue)")
        }
    }

    @Test("All blocklist names are non-empty")
    func allNamesNonEmpty() {
        for entry in BlocklistRegistry.allLists {
            #expect(!entry.name.isEmpty, "Blocklist with id '\(entry.id)' has empty name")
        }
    }

    @Test("All blocklist descriptions are non-empty")
    func allDescriptionsNonEmpty() {
        for entry in BlocklistRegistry.allLists {
            #expect(!entry.description.isEmpty, "Blocklist '\(entry.name)' has empty description")
        }
    }

    @Test("Category filter returns correct entries")
    func categoryFilterWorks() {
        let generalLists = BlocklistRegistry.lists(for: .general)
        for entry in generalLists {
            #expect(entry.category == .general)
        }
    }
}
