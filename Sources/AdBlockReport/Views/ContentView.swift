import SwiftUI

struct ContentView: View {
    @State private var viewModel = TestViewModel()

    var body: some View {
        TabView {
            Tab("Test", systemImage: "shield.checkered") {
                NavigationStack {
                    HomeView(viewModel: viewModel)
                }
            }
            Tab("History", systemImage: "clock.arrow.circlepath") {
                NavigationStack {
                    HistoryView()
                }
            }
            Tab("Settings", systemImage: "gear") {
                NavigationStack {
                    SettingsView(viewModel: viewModel)
                }
            }
        }
    }
}
