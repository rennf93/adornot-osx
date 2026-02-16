import SwiftUI
import SwiftData

@main
struct AdBlockReportApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
        .modelContainer(for: TestReport.self)
    }
}
