import Foundation

struct TestDomain: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let hostname: String
    let provider: String
    let category: TestCategory

    init(hostname: String, provider: String, category: TestCategory) {
        self.id = UUID()
        self.hostname = hostname
        self.provider = provider
        self.category = category
    }
}
