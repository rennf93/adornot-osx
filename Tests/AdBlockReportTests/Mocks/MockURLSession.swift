import Foundation
@testable import AdBlockReport

final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    var responses: [String: Result<(Data, URLResponse), Error>] = [:]

    func setSuccess(for hostname: String, statusCode: Int = 200) {
        let url = URL(string: "https://\(hostname)/")!
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        responses[hostname] = .success((Data(), response))
    }

    func setFailure(for hostname: String, error: URLError.Code) {
        let url = URL(string: "https://\(hostname)/")!
        responses[hostname] = .failure(URLError(error, userInfo: [NSURLErrorFailingURLErrorKey: url]))
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let host = request.url?.host else {
            throw URLError(.badURL)
        }
        guard let result = responses[host] else {
            throw URLError(.cannotFindHost)
        }
        return try result.get()
    }
}
