import Testing
import SwiftUI
@testable import AdBlockReport

@Test func scoreThresholdColorGreen() {
    #expect(ScoreThreshold.color(for: 60) == .green)
    #expect(ScoreThreshold.color(for: 100) == .green)
    #expect(ScoreThreshold.color(for: 75.5) == .green)
}

@Test func scoreThresholdColorOrange() {
    #expect(ScoreThreshold.color(for: 30) == .orange)
    #expect(ScoreThreshold.color(for: 59.9) == .orange)
    #expect(ScoreThreshold.color(for: 45) == .orange)
}

@Test func scoreThresholdColorRed() {
    #expect(ScoreThreshold.color(for: 0) == .red)
    #expect(ScoreThreshold.color(for: 29.9) == .red)
    #expect(ScoreThreshold.color(for: 15) == .red)
}

@Test func scoreThresholdLabelStrong() {
    #expect(ScoreThreshold.label(for: 60) == "Strong Protection")
    #expect(ScoreThreshold.label(for: 100) == "Strong Protection")
}

@Test func scoreThresholdLabelModerate() {
    #expect(ScoreThreshold.label(for: 30) == "Moderate Protection")
    #expect(ScoreThreshold.label(for: 59) == "Moderate Protection")
}

@Test func scoreThresholdLabelWeak() {
    #expect(ScoreThreshold.label(for: 0) == "Weak Protection")
    #expect(ScoreThreshold.label(for: 29) == "Weak Protection")
}

@Test func scoreThresholdBoundaryExact60() {
    #expect(ScoreThreshold.color(for: 60) == .green)
    #expect(ScoreThreshold.label(for: 60) == "Strong Protection")
}

@Test func scoreThresholdBoundaryExact30() {
    #expect(ScoreThreshold.color(for: 30) == .orange)
    #expect(ScoreThreshold.label(for: 30) == "Moderate Protection")
}
