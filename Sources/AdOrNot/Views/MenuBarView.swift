#if os(macOS)
import SwiftUI
import SwiftData

struct MenuBarLabel: View {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    var body: some View {
        MenuBarLabelContent()
            .modelContainer(modelContainer)
    }
}

private struct MenuBarLabelContent: View {
    @Query(sort: \TestReport.date, order: .reverse)
    private var reports: [TestReport]

    var body: some View {
        let latest = reports.first
        if let score = latest?.overallScore {
            Label(
                "\(Int(score))%",
                systemImage: "eye"
            )
        } else {
            Label("AdOrNot", systemImage: "eye")
        }
    }
}

struct MenuBarContentView: View {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    var body: some View {
        MenuBarContentViewInner()
            .modelContainer(modelContainer)
    }
}

private struct MenuBarContentViewInner: View {
    @Query(sort: \TestReport.date, order: .reverse)
    private var reports: [TestReport]

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if let report = reports.first {
            Text("\(Int(report.overallScore))% — \(ScoreThreshold.label(for: report.overallScore))")
            Text(report.date.formatted(date: .abbreviated, time: .shortened))
            Text("\(report.blockedDomains)/\(report.totalDomains) domains blocked")
        } else {
            Text("No tests yet")
        }

        Divider()

        Button("Open AdOrNot") {
            openWindow(id: "main")
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        .keyboardShortcut("o")

        Divider()

        Button("Quit AdOrNot") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
#endif
