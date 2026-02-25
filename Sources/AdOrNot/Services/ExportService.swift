import Foundation

enum ExportService {

    static func generateTextReport(_ report: TestReport) -> String {
        var text = """
        AdOrNot
        ==============
        Date: \(report.date.formatted(date: .long, time: .shortened))
        Device: \(report.deviceName)
        OS: \(report.osVersion)
        Duration: \(String(format: "%.1f", report.durationSeconds))s
        Test Mode: \(report.testModeEnum.label)

        Overall Score: \(String(format: "%.0f", report.overallScore))%
        Blocked: \(report.blockedDomains)/\(report.totalDomains) domains

        Category Breakdown:
        """

        for category in TestCategory.allCases {
            if let score = report.categoryScores[category.rawValue] {
                text += "\n  \(category.rawValue): \(String(format: "%.0f", score))%"
            }
        }

        text += "\n\nDetailed Results:\n"

        let results = report.results
        let grouped = Dictionary(grouping: results, by: { $0.domain.category })
        for category in TestCategory.allCases {
            guard let catResults = grouped[category] else { continue }
            text += "\n[\(category.rawValue)]\n"
            for result in catResults.sorted(by: { $0.domain.provider < $1.domain.provider }) {
                let status = result.isBlocked ? "[BLOCKED]" : "[EXPOSED]"
                text += "  \(status) \(result.domain.hostname) (\(result.domain.provider))\n"
            }
        }

        return text
    }

    static func generateJSONData(_ report: TestReport) -> Data? {
        struct ExportableReport: Codable {
            let date: Date
            let device: String
            let osVersion: String
            let testMode: String
            let overallScore: Double
            let categoryScores: [String: Double]
            let results: [ExportableResult]
        }

        struct ExportableResult: Codable {
            let hostname: String
            let provider: String
            let category: String
            let isBlocked: Bool
            let responseTimeMs: Double?
        }

        let exportable = ExportableReport(
            date: report.date,
            device: report.deviceName,
            osVersion: report.osVersion,
            testMode: report.testModeEnum.label,
            overallScore: report.overallScore,
            categoryScores: report.categoryScores,
            results: report.results.map {
                ExportableResult(
                    hostname: $0.domain.hostname,
                    provider: $0.domain.provider,
                    category: $0.domain.category.rawValue,
                    isBlocked: $0.isBlocked,
                    responseTimeMs: $0.responseTimeMs
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(exportable)
    }
}
