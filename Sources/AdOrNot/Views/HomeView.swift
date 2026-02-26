import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var viewModel: TestViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var availableWidth: CGFloat = 600

    private var heroCircleSize: CGFloat {
        min(140, max(60, availableWidth * 0.22))
    }

    private var heroIconSize: CGFloat {
        heroCircleSize * 0.46
    }

    private var heroTitleSize: CGFloat {
        min(28, max(18, availableWidth * 0.045))
    }

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
        .navigationTitle("AdOrNot")
        #if os(macOS)
        .navigationSubtitle(viewModel.state == .idle ? "Ready to scan" : "")
        #endif
    }

    private var idleContent: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: Theme.spacingXL) {
                    Spacer(minLength: Theme.spacingXL)

                    heroSection
                    statsRow

                    if viewModel.pihole.isPiholeConfigured {
                        testModePicker
                    }

                    Spacer(minLength: Theme.spacingMD)

                    if viewModel.networkUnavailable {
                        networkWarning
                    }

                    startButton

                    Spacer(minLength: Theme.spacingXL)
                }
                .padding(.horizontal, Theme.spacingXL)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newWidth in
                    availableWidth = newWidth
                }
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: Theme.spacingLG) {
            ZStack {
                Circle()
                    .fill(Theme.brandBlue.opacity(0.15))
                    .frame(width: heroCircleSize, height: heroCircleSize)
                    .blur(radius: 20)

                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: heroIconSize, height: heroIconSize)
                    .clipShape(RoundedRectangle(cornerRadius: heroIconSize * 0.22))
                    .shadow(color: Theme.brandBlue.opacity(0.4), radius: 16, y: 6)
            }

            VStack(spacing: Theme.spacingSM) {
                Text("Test Your Ad Blocker")
                    .font(.system(size: heroTitleSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Check if your DNS filter or ad blocker is effectively blocking known advertising, analytics, and tracking domains.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: Theme.spacingMD) {
            StatCard(
                title: "Domains",
                value: "\(viewModel.domainsToTest.count)",
                icon: "globe"
            )
            StatCard(
                title: "Categories",
                value: "\(viewModel.selectedCategories.count)",
                icon: "folder.fill"
            )
            StatCard(
                title: "Concurrency",
                value: "8x",
                icon: "bolt.fill"
            )
        }
    }

    // MARK: - Test Mode Picker

    private var testModePicker: some View {
        VStack(spacing: Theme.spacingSM) {
            Picker("Test Mode", selection: $viewModel.testMode) {
                ForEach(TestMode.allCases) { mode in
                    Label(mode.label, systemImage: mode.systemImage).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text(viewModel.testMode.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .glassCard(padding: Theme.spacingMD)
    }

    // MARK: - Network Warning

    private var networkWarning: some View {
        WarningBanner(icon: "wifi.slash", message: "No network connection")
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            viewModel.startTest(modelContext: modelContext)
        } label: {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "play.fill")
                Text("Start Test")
            }
            .frame(maxWidth: 280)
        }
        .buttonStyle(GradientButtonStyle(isDisabled: viewModel.networkUnavailable))
        .disabled(viewModel.networkUnavailable)
    }
}

#Preview("Idle") {
    NavigationStack {
        HomeView(viewModel: PreviewData.makeIdleViewModel())
    }
    .modelContainer(.preview)
}

#Preview("Running") {
    NavigationStack {
        HomeView(viewModel: PreviewData.makeRunningViewModel())
    }
    .modelContainer(.preview)
}

#Preview("Completed") {
    NavigationStack {
        HomeView(viewModel: PreviewData.makeCompletedViewModel())
    }
    .modelContainer(.preview)
}
