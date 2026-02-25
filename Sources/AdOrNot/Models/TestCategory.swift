import Foundation

enum TestCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case ads = "Ads"
    case analytics = "Analytics"
    case errorTrackers = "Error Trackers"
    case socialTrackers = "Social Trackers"
    case mix = "Mix"
    case oems = "OEMs"
    case piholeBlocklists = "Pi-hole Lists"

    var id: String { rawValue }

    /// The standard 6 categories used in the default domain registry.
    static var standardCases: [TestCategory] {
        [.ads, .analytics, .errorTrackers, .socialTrackers, .mix, .oems]
    }

    var systemImage: String {
        switch self {
        case .ads: "megaphone.fill"
        case .analytics: "chart.bar.fill"
        case .errorTrackers: "ladybug.fill"
        case .socialTrackers: "person.2.fill"
        case .mix: "square.grid.2x2.fill"
        case .oems: "cpu.fill"
        case .piholeBlocklists: "shield.checkered"
        }
    }

    var description: String {
        switch self {
        case .ads: "Advertising networks and ad-serving domains"
        case .analytics: "Web analytics and user tracking services"
        case .errorTrackers: "Error reporting and crash analytics"
        case .socialTrackers: "Social media tracking pixels and APIs"
        case .mix: "Mixed advertising and analytics services"
        case .oems: "Device manufacturer telemetry and tracking"
        case .piholeBlocklists: "Pi-hole blocklist source URLs"
        }
    }
}
