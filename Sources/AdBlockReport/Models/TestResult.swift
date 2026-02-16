import Foundation

struct TestResult: Identifiable, Codable, Sendable {
    let id: UUID
    let domain: TestDomain
    let isBlocked: Bool
    let responseTimeMs: Double?
    let errorDescription: String?
    let timestamp: Date

    init(
        domain: TestDomain,
        isBlocked: Bool,
        responseTimeMs: Double? = nil,
        errorDescription: String? = nil
    ) {
        self.id = UUID()
        self.domain = domain
        self.isBlocked = isBlocked
        self.responseTimeMs = responseTimeMs
        self.errorDescription = errorDescription
        self.timestamp = Date()
    }
}
