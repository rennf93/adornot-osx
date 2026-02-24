import SwiftUI

/// Shared score-to-color/level mapping used across the entire app.
enum ScoreThreshold {
    static let good: Double = 60
    static let moderate: Double = 30

    static func color(for score: Double) -> Color {
        if score >= good { Theme.scoreGood }
        else if score >= moderate { Theme.scoreModerate }
        else { Theme.scoreWeak }
    }

    static func label(for score: Double) -> String {
        if score >= good { "Strong Protection" }
        else if score >= moderate { "Moderate Protection" }
        else { "Weak Protection" }
    }
}
