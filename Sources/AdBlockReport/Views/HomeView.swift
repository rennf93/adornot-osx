import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var viewModel: TestViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                idleContent
            case .running:
                TestingView(viewModel: viewModel)
            case .completed:
                ResultsView(viewModel: viewModel)
            }
        }
        .navigationTitle("AdBlock Report")
    }

    private var idleContent: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "shield.checkered")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            Text("Test Your Ad Blocker")
                .font(.largeTitle.bold())

            Text("""
            Check if your DNS filter or ad blocker is effectively blocking \
            known advertising, analytics, and tracking domains.
            """)
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)

            Text("\(viewModel.domainsToTest.count) domains across \(viewModel.selectedCategories.count) categories")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            Spacer()

            Button {
                viewModel.startTest(modelContext: modelContext)
            } label: {
                Label("Start Test", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}
