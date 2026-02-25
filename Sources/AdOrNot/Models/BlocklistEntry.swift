import Foundation

struct BlocklistEntry: Identifiable, Sendable {
    let id: String
    let name: String
    let author: String
    let description: String
    let websiteURL: URL
    let category: Category
    let format: Format

    enum Category: String, CaseIterable, Sendable {
        case general = "General"
        case privacy = "Privacy"
        case malware = "Malware"
        case social = "Social"
    }

    enum Format: String, CaseIterable, Sendable {
        case hosts = "Hosts"
        case adblockPlus = "ABP"
        case domainList = "Domains"
    }
}
