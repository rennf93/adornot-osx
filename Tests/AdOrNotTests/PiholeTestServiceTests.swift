import Testing
import Foundation
@testable import AdOrNot

@Test func piholeAuthSuccess() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10",
        password: "testpass",
        session: mockSession
    )

    let result = await service.authenticate()
    #expect(result == true)
}

@Test func piholeAuthFailure() async {
    let mockSession = PiholeMockURLSession()

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10",
        password: "wrong",
        session: mockSession
    )

    let result = await service.authenticate()
    #expect(result == false)
}

@Test func piholeLastErrorOnAuthFailure() async {
    let mockSession = PiholeMockURLSession()

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10",
        password: "wrong",
        session: mockSession
    )

    _ = await service.authenticate()
    let error = await service.lastError
    #expect(error != nil)
}

@Test func piholeAuthFailureReturnsEmptyBlocklists() async {
    let mockSession = PiholeMockURLSession()

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10",
        password: "wrong",
        session: mockSession
    )

    let urls = await service.fetchBlocklistURLs()
    #expect(urls.isEmpty)
}

@Test func piholeFetchBlocklistURLs() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()
    mockSession.setBlocklists([
        ("https://example.com/hosts.txt", true, "block"),
        ("https://other.com/ads.txt", true, "block"),
        ("https://allowed.com/list.txt", true, "allow"),
        ("https://disabled.com/hosts.txt", false, "block"),
    ])

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10",
        password: "test",
        session: mockSession
    )

    let urls = await service.fetchBlocklistURLs()
    #expect(urls.count == 2)
    #expect(urls.contains("https://example.com/hosts.txt"))
    #expect(urls.contains("https://other.com/ads.txt"))
}

@Test func piholeFetchBlocklistDomains() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()
    mockSession.setBlocklists([
        ("https://example.com/hosts.txt", true, "block"),
    ])
    mockSession.setBlocklistContent("https://example.com/hosts.txt", """
    # Comment line
    0.0.0.0 ad.example.com
    0.0.0.0 tracker.example.com
    127.0.0.1 analytics.example.com
    0.0.0.0 localhost
    """)

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10",
        password: "test",
        session: mockSession
    )

    let domains = await service.fetchBlocklistDomains(sampleSize: 100)
    let hostnames = domains.map(\.hostname)
    #expect(domains.count == 3)
    #expect(hostnames.contains("ad.example.com"))
    #expect(hostnames.contains("tracker.example.com"))
    #expect(hostnames.contains("analytics.example.com"))
    // localhost should be excluded
    #expect(!hostnames.contains("localhost"))
    // All should have piholeBlocklists category
    #expect(domains.allSatisfy { $0.category == .piholeBlocklists })
}

@Test func piholeFetchBlocklistDomainsSampling() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()
    mockSession.setBlocklists([
        ("https://example.com/hosts.txt", true, "block"),
    ])

    // Generate a large hosts file with 500 domains
    var hostsContent = "# Large blocklist\n"
    for i in 0..<500 {
        hostsContent += "0.0.0.0 domain\(i).example.com\n"
    }
    mockSession.setBlocklistContent("https://example.com/hosts.txt", hostsContent)

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10",
        password: "test",
        session: mockSession
    )

    let domains = await service.fetchBlocklistDomains(sampleSize: 128)
    #expect(domains.count == 128)
}

@Test func piholeFetchBlocklistDomainsDeduplicates() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()
    mockSession.setBlocklists([
        ("https://list1.com/hosts.txt", true, "block"),
        ("https://list2.com/hosts.txt", true, "block"),
    ])
    // Same domains in both lists
    mockSession.setBlocklistContent("https://list1.com/hosts.txt", """
    0.0.0.0 ad.example.com
    0.0.0.0 tracker.example.com
    """)
    mockSession.setBlocklistContent("https://list2.com/hosts.txt", """
    0.0.0.0 ad.example.com
    0.0.0.0 other.example.com
    """)

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10",
        password: "test",
        session: mockSession
    )

    let domains = await service.fetchBlocklistDomains(sampleSize: 100)
    // ad.example.com appears in both lists but should only appear once
    #expect(domains.count == 3)
}

@Test func piholeParseHostsFileFormats() {
    let content = """
    # Comment
    ! ABP-style comment
    0.0.0.0 ad.example.com
    127.0.0.1 tracker.example.com
    :: ipv6.example.com
    ::1 ipv6b.example.com
    bare.example.com
    0.0.0.0 inline.example.com # inline comment
    0.0.0.0 localhost
    0.0.0.0 localhost.localdomain
    0.0.0.0 broadcasthost
    notadomain
    0.0.0.0 has/path.com

    0.0.0.0 tabbed.example.com
    """

    let domains = PiholeTestService.parseHostsFile(content)
    #expect(domains.contains("ad.example.com"))
    #expect(domains.contains("tracker.example.com"))
    #expect(domains.contains("ipv6.example.com"))
    #expect(domains.contains("ipv6b.example.com"))
    #expect(domains.contains("bare.example.com"))
    #expect(domains.contains("inline.example.com"))
    #expect(domains.contains("tabbed.example.com"))
    #expect(!domains.contains("localhost"))
    #expect(!domains.contains("localhost.localdomain"))
    #expect(!domains.contains("broadcasthost"))
    #expect(!domains.contains("notadomain"))
    #expect(!domains.contains("has/path.com"))
}

// MARK: - URL Normalization Tests

@Test func piholeAcceptsBareIP() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()

    let service = PiholeTestService(
        baseURL: "192.168.1.10",
        password: "test",
        session: mockSession
    )

    let result = await service.authenticate()
    #expect(result == true)
}

@Test func piholeAcceptsIPWithPort() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()

    let service = PiholeTestService(
        baseURL: "192.168.1.10:8080",
        password: "test",
        session: mockSession
    )

    let result = await service.authenticate()
    #expect(result == true)
}

@Test func piholeStripsApiAuthSuffix() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10/api/auth",
        password: "test",
        session: mockSession
    )

    let result = await service.authenticate()
    #expect(result == true)
}

@Test func piholeStripsApiSuffix() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()

    let service = PiholeTestService(
        baseURL: "http://192.168.1.10/api",
        password: "test",
        session: mockSession
    )

    let result = await service.authenticate()
    #expect(result == true)
}

@Test func piholeHandlesWhitespace() async {
    let mockSession = PiholeMockURLSession()
    mockSession.setAuthSuccess()

    let service = PiholeTestService(
        baseURL: "  192.168.1.10  ",
        password: "test",
        session: mockSession
    )

    let result = await service.authenticate()
    #expect(result == true)
}

// MARK: - Pi-hole Mock URL Session

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
