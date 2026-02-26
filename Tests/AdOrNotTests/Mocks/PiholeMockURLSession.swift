import Foundation
@testable import AdOrNot

final class PiholeMockURLSession: URLSessionProtocol, @unchecked Sendable {
    private var authSuccess = false
    private var blocklists: [(address: String, enabled: Bool, type: String)] = []
    private var blocklistContents: [String: String] = [:]

    func setAuthSuccess() {
        authSuccess = true
    }

    func setBlocklists(_ lists: [(String, Bool, String)]) {
        blocklists = lists.map { (address: $0.0, enabled: $0.1, type: $0.2) }
    }

    func setBlocklistContent(_ url: String, _ content: String) {
        blocklistContents[url] = content
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw URLError(.badURL)
        }

        let urlString = url.absoluteString
        let path = url.path

        // Auth endpoint
        if path.hasSuffix("/api/auth") && request.httpMethod == "POST" {
            if authSuccess {
                let json = """
                {"session": {"sid": "mock-sid"}}
                """.data(using: .utf8)!
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (json, response)
            } else {
                throw URLError(.userAuthenticationRequired)
            }
        }

        // Lists endpoint
        if path.hasSuffix("/api/lists") {
            let entries = blocklists.map { entry in
                """
                {"address": "\(entry.address)", "enabled": \(entry.enabled), "type": "\(entry.type)"}
                """
            }.joined(separator: ", ")

            let json = """
            {"lists": [\(entries)]}
            """.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (json, response)
        }

        // Blocklist file downloads
        if let content = blocklistContents[urlString] {
            let data = content.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }

        throw URLError(.unsupportedURL)
    }
}
