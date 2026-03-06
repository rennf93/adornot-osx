import SwiftUI
import SwiftData

@main
struct AdOrNotApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: TestReport.self)
        } catch {
            modelContainer = try! ModelContainer(
                for: TestReport.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            LaunchView()
        }
        .modelContainer(modelContainer)

        #if os(macOS)
        MenuBarExtra {
            MenuBarContentView(modelContainer: modelContainer)
        } label: {
            MenuBarLabel(modelContainer: modelContainer)
        }
        .menuBarExtraStyle(.menu)
        #endif
    }
}
