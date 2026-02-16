import SwiftUI
import SwiftData

@main
struct AdBlockReportApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TestReport.self)
    }
}
