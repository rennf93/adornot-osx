import SwiftUI

struct ContentView: View {
    @State private var viewModel = TestViewModel()
    @State private var selectedTab: AppTab = .test

    enum AppTab: String, CaseIterable {
        case test = "Test"
        case domains = "Domains"
        case history = "History"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .test: "eye"
            case .domains: "list.bullet.rectangle"
            case .history: "clock.arrow.circlepath"
            case .settings: "gear"
            }
        }
    }

    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
        } detail: {
            detailView
        }
        .frame(minWidth: 720, minHeight: 520)
        #else
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Tab(tab.rawValue, systemImage: tab.icon, value: tab) {
                    NavigationStack {
                        tabContent(for: tab)
                    }
                }
            }
        }
        #endif
    }

    // MARK: - macOS Sidebar

    private var sidebar: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Brand header
                VStack(spacing: Theme.spacingSM) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Text("AdOrNot")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, Theme.spacingLG)

                Divider()
                    .overlay(Color.white.opacity(0.1))

                // Navigation items
                VStack(spacing: Theme.spacingXS) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        sidebarButton(for: tab)
                    }
                }
                .padding(.horizontal, Theme.spacingSM)
                .padding(.top, Theme.spacingMD)

                Spacer()

                // Version info
                Text("v\(AppVersion.current)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.bottom, Theme.spacingMD)
            }
        }
    }

    private func sidebarButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 24)
                Text(tab.rawValue)
                    .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .regular))
                Spacer()
            }
            .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.6))
            .padding(.horizontal, Theme.spacingSM)
            .padding(.vertical, Theme.spacingSM)
            .background {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(Color.white.opacity(0.12))
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Detail Content

    private var detailView: some View {
        NavigationStack {
            tabContent(for: selectedTab)
        }
        .id(selectedTab)
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .test:
            HomeView(viewModel: viewModel)
        case .domains:
            DomainsView()
        case .history:
            HistoryView()
        case .settings:
            SettingsView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(.preview)
}
