import Foundation

enum ScoreCalculator {

    struct Scores {
        let overall: Double
        let byCategory: [TestCategory: Double]

        var byCategoryRawValue: [String: Double] {
            Dictionary(uniqueKeysWithValues: byCategory.map { ($0.key.rawValue, $0.value) })
        }
    }

    static func calculate(from results: [TestResult]) -> Scores {
        guard !results.isEmpty else {
            return Scores(overall: 0, byCategory: [:])
        }

        let blocked = results.filter(\.isBlocked).count
        let overall = (Double(blocked) / Double(results.count)) * 100.0

        let grouped = Dictionary(grouping: results, by: { $0.domain.category })
        var byCategory: [TestCategory: Double] = [:]
        for (category, catResults) in grouped {
            let catBlocked = catResults.filter(\.isBlocked).count
            byCategory[category] = (Double(catBlocked) / Double(catResults.count)) * 100.0
        }

        return Scores(overall: overall, byCategory: byCategory)
    }
}
