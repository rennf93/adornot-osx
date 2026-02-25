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
    var testMode: String = "Standard"

    var testModeEnum: TestMode {
        TestMode(rawValue: testMode) ?? .standard
    }

    init(
        results: [TestResult],
        duration: Double,
        deviceName: String,
        osVersion: String,
        testMode: TestMode = .standard
    ) {
        self.id = UUID()
        self.date = Date()
        let total = results.count
        let blocked = results.filter(\.isBlocked).count
        self.totalDomains = total
        self.blockedDomains = blocked
        self.overallScore = results.isEmpty
            ? 0
            : (Double(blocked) / Double(total)) * 100.0

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
        self.testMode = testMode.rawValue
    }

    var results: [TestResult] {
        (try? JSONDecoder().decode([TestResult].self, from: resultsData)) ?? []
    }
}
