import Foundation
import SwiftData

@Model
final class TestReport {
    var id: UUID
    var date: Date
    var totalDomains: Int
    var blockedDomains: Int
    var overallScore: Double
    var categoryScores: [String: Double]
    var resultsData: Data
    var durationSeconds: Double
    var deviceName: String
    var osVersion: String

    init(
        results: [TestResult],
        duration: Double,
        deviceName: String,
        osVersion: String
    ) {
        self.id = UUID()
        self.date = Date()
        self.totalDomains = results.count
        self.blockedDomains = results.filter(\.isBlocked).count
        self.overallScore = results.isEmpty
            ? 0
            : (Double(self.blockedDomains) / Double(self.totalDomains)) * 100.0

        var scores: [String: Double] = [:]
        let grouped = Dictionary(grouping: results, by: { $0.domain.category })
        for (category, catResults) in grouped {
            let blocked = catResults.filter(\.isBlocked).count
            scores[category.rawValue] = (Double(blocked) / Double(catResults.count)) * 100.0
        }
        self.categoryScores = scores

        self.resultsData = (try? JSONEncoder().encode(results)) ?? Data()
        self.durationSeconds = duration
        self.deviceName = deviceName
        self.osVersion = osVersion
    }

    var results: [TestResult] {
        (try? JSONDecoder().decode([TestResult].self, from: resultsData)) ?? []
    }
}
