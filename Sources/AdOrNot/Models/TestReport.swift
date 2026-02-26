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
        self.totalDomains = results.count
        self.blockedDomains = results.filter(\.isBlocked).count

        let scores = ScoreCalculator.calculate(from: results)
        self.overallScore = scores.overall
        self.categoryScores = scores.byCategoryRawValue

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
