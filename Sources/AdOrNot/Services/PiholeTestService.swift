import Foundation

/// Fetches blocklist domains from a Pi-hole v6 instance.
/// Downloads the actual blocklist files and parses ad/tracking domains from them.
actor PiholeTestService {

    private let session: URLSessionProtocol
    private let baseURL: String
    private let password: String
    private var sessionID: String?
    private(set) var lastError: String?

    init(
        baseURL: String,
        password: String,
        session: URLSessionProtocol? = nil
    ) {
        self.baseURL = Self.normalizeURL(baseURL)
        self.password = password
        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 15
            config.timeoutIntervalForResource = 30
            config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            self.session = URLSession(configuration: config)
        }
    }

    /// Normalizes user input into a proper base URL.
    private static func normalizeURL(_ input: String) -> String {
        var url = input.trimmingCharacters(in: .whitespacesAndNewlines)
        while url.hasSuffix("/") { url = String(url.dropLast()) }
        if url.hasSuffix("/api/auth") { url = String(url.dropLast("/api/auth".count)) }
        if url.hasSuffix("/api") { url = String(url.dropLast("/api".count)) }
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            url = "http://\(url)"
        }
        return url
    }

    // MARK: - Authentication

    func authenticate() async -> Bool {
        let endpoint = "\(baseURL)/api/auth"
        guard let url = URL(string: endpoint) else {
            lastError = "Invalid URL: \(endpoint) — check Pi-hole host address"
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["password": password])

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                lastError = "Invalid response from \(baseURL)"
                return false
            }

            if httpResponse.statusCode == 401 {
                lastError = "Wrong password — check Pi-hole password"
                return false
            }

            guard httpResponse.statusCode == 200 else {
                lastError = "Pi-hole returned HTTP \(httpResponse.statusCode) at \(endpoint)"
                return false
            }

            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            guard let sid = authResponse.session.sid, !sid.isEmpty else {
                lastError = "Authentication failed — invalid session from Pi-hole"
                return false
            }

            sessionID = sid
            lastError = nil
            return true
        } catch let urlError as URLError {
            switch urlError.code {
            case .timedOut:
                lastError = "Connection timed out — is Pi-hole running at \(baseURL)?"
            case .cannotFindHost:
                lastError = "Host not found — check Pi-hole address"
            case .cannotConnectToHost:
                lastError = "Cannot connect — is Pi-hole running at \(baseURL)?"
            case .notConnectedToInternet:
                lastError = "No internet connection"
            default:
                lastError = "Network error: \(urlError.localizedDescription)"
            }
            return false
        } catch {
            lastError = "Pi-hole auth error: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Fetch Blocklist URLs

    /// Returns the enabled blocklist URLs configured in Pi-hole.
    func fetchBlocklistURLs() async -> [String] {
        guard await authenticate(), let sid = sessionID else {
            return []
        }

        let endpoint = "\(baseURL)/api/lists"
        guard let url = URL(string: endpoint) else {
            lastError = "Invalid URL: \(endpoint)"
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(sid, forHTTPHeaderField: "sid")

        do {
            let (data, _) = try await session.data(for: request)
            let response = try JSONDecoder().decode(ListsResponse.self, from: data)
            return response.lists
                .filter { $0.enabled && $0.type == "block" }
                .map(\.address)
        } catch {
            lastError = "Failed to fetch blocklists: \(error.localizedDescription)"
            return []
        }
    }

    // MARK: - Fetch Blocklist Domains

    /// Downloads blocklist files from Pi-hole's configured URLs and parses
    /// the actual ad/tracking domains from them. Returns a sample of domains
    /// as TestDomain objects ready for HEAD request testing.
    /// Sample size scales logarithmically: 200 × log₁₀(total), max 2000.
    /// Small lists are tested fully; large lists get a diminishing sample.
    func fetchBlocklistDomains(sampleSize: Int? = nil) async -> [TestDomain] {
        let urls = await fetchBlocklistURLs()
        if urls.isEmpty { return [] }

        // Map each domain to the blocklist it came from (first occurrence wins)
        var domainToList: [String: String] = [:]

        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            let listName = Self.friendlyListName(from: url)
            do {
                let request = URLRequest(url: url)
                let (data, _) = try await session.data(for: request)
                if let content = String(data: data, encoding: .utf8) {
                    let domains = Self.parseHostsFile(content)
                    for domain in domains {
                        if domainToList[domain] == nil {
                            domainToList[domain] = listName
                        }
                    }
                }
            } catch {
                // Skip failed downloads — some lists may be temporarily unavailable
                continue
            }
        }

        if domainToList.isEmpty {
            lastError = "No domains found in blocklist files"
            return []
        }

        // Logarithmic scaling: 200 × log₁₀(total), capped at 2000
        // Small lists tested fully, large lists get diminishing ratio
        let effectiveSize = sampleSize ?? min(Int(200.0 * log10(Double(domainToList.count))), 2000)
        let sampled = Array(domainToList.keys.shuffled().prefix(effectiveSize))
        return sampled.map {
            TestDomain(hostname: $0, provider: domainToList[$0] ?? "Unknown", category: .piholeBlocklists)
        }
    }

    // MARK: - Helpers

    /// Extracts a human-readable name from a blocklist URL.
    /// GitHub raw URLs → "user/repo", others → hostname.
    static func friendlyListName(from url: URL) -> String {
        if url.host == "raw.githubusercontent.com" {
            let parts = url.pathComponents
            if parts.count >= 3 {
                return "\(parts[1])/\(parts[2])"
            }
        }
        return url.host ?? url.absoluteString
    }

    // MARK: - Hosts File Parser

    /// Parses a hosts-format blocklist file and extracts domain names.
    /// Handles formats: "0.0.0.0 domain", "127.0.0.1 domain", bare "domain" lines.
    static func parseHostsFile(_ content: String) -> [String] {
        let skipDomains: Set<String> = [
            "localhost", "localhost.localdomain", "broadcasthost", "local",
            "ip6-localhost", "ip6-loopback", "ip6-localnet",
            "ip6-mcastprefix", "ip6-allnodes", "ip6-allrouters", "ip6-allhosts",
        ]
        let ipPrefixes: Set<String> = ["0.0.0.0", "127.0.0.1", "::", "::1"]

        var domains: [String] = []

        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") || trimmed.hasPrefix("!") { continue }

            // Strip inline comments
            let withoutComment = trimmed.components(separatedBy: "#").first ?? trimmed

            let parts = withoutComment.components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
            guard !parts.isEmpty else { continue }

            let domain: String
            if ipPrefixes.contains(parts[0]) {
                guard parts.count >= 2 else { continue }
                domain = parts[1].lowercased()
            } else {
                domain = parts[0].lowercased()
            }

            if skipDomains.contains(domain) { continue }
            if !domain.contains(".") { continue }
            if domain.contains("/") || domain.contains(":") { continue }

            domains.append(domain)
        }

        return domains
    }

    // MARK: - Codable Types

    private struct AuthResponse: Codable {
        let session: SessionData
    }

    private struct SessionData: Codable {
        let sid: String?
    }

    private struct ListsResponse: Codable {
        let lists: [BlocklistEntry]
    }

    private struct BlocklistEntry: Codable {
        let address: String
        let enabled: Bool
        let type: String
    }
}
