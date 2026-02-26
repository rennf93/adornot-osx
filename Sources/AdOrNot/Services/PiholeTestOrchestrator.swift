import Foundation
import Observation

@Observable
@MainActor
final class PiholeTestOrchestrator {

    var piholeHost: String = UserDefaults.standard.string(forKey: "piholeHost") ?? ""
    var piholeError: String?

    var isPiholeConfigured: Bool {
        !piholeHost.isEmpty && KeychainHelper.load(key: "piholePassword") != nil
    }

    func savePiholeHost(_ host: String) {
        piholeHost = host
        UserDefaults.standard.set(host, forKey: "piholeHost")
    }

    func testPiholeConnection() async -> Bool {
        let password = KeychainHelper.load(key: "piholePassword") ?? ""
        let service = PiholeTestService(baseURL: piholeHost, password: password)
        let success = await service.authenticate()
        if !success {
            piholeError = await service.lastError
        } else {
            piholeError = nil
        }
        return success
    }

    /// Fetches domains from Pi-hole blocklists. Returns nil on failure (sets piholeError).
    func fetchDomains(requestTimeout: Double) async -> [TestDomain]? {
        let password = KeychainHelper.load(key: "piholePassword") ?? ""
        let piholeService = PiholeTestService(baseURL: piholeHost, password: password)
        let blocklistDomains = await piholeService.fetchBlocklistDomains()

        if blocklistDomains.isEmpty {
            let error = await piholeService.lastError
            piholeError = error ?? "No domains found in Pi-hole blocklists"
            return nil
        }

        return blocklistDomains
    }
}
