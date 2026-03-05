import Foundation

protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func invalidateAndCancel()
}

extension URLSession: URLSessionProtocol {}
