import Foundation

enum TestMode: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case pihole = "Pi-hole"

    var id: String { rawValue }

    var label: String { rawValue }

    var description: String {
        switch self {
        case .standard:
            return "Test via live network requests to each domain"
        case .pihole:
            return "Test which domains your Pi-hole blocks"
        }
    }

    var systemImage: String {
        switch self {
        case .standard:
            return "network"
        case .pihole:
            return "shield.checkered"
        }
    }
}
