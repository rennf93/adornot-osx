import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: TestViewModel

    var body: some View {
        Form {
            Section("Test Categories") {
                ForEach(TestCategory.allCases) { category in
                    Toggle(isOn: Binding(
                        get: { viewModel.selectedCategories.contains(category) },
                        set: { isOn in
                            if isOn {
                                viewModel.selectedCategories.insert(category)
                            } else {
                                viewModel.selectedCategories.remove(category)
                            }
                        }
                    )) {
                        Label {
                            VStack(alignment: .leading) {
                                Text(category.rawValue)
                                Text("\(DomainRegistry.domains(for: category).count) domains")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: category.systemImage)
                        }
                    }
                }
            }

            Section("Domain Count") {
                Text("\(viewModel.domainsToTest.count) domains selected")
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Total Domains", value: "\(DomainRegistry.allDomains.count)")

                NavigationLink("About This App") {
                    aboutView
                }
            }
        }
        .navigationTitle("Settings")
    }

    private var aboutView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("AdBlock Report")
                    .font(.largeTitle.bold())

                Text("""
                This app tests the effectiveness of your DNS-level ad blocker \
                or content filter by attempting to reach known advertising, \
                analytics, and tracking domains.
                """)

                Text("How It Works")
                    .font(.headline)

                Text("""
                For each domain in our curated list, the app sends an HTTP HEAD \
                request. If the request fails because DNS resolution is blocked, \
                the domain is counted as blocked. The percentage of blocked \
                domains gives you a score indicating how effective your ad \
                blocker is.
                """)

                Text("""
                The domain list includes well-known ad networks (Google Ads, \
                DoubleClick), analytics services (Google Analytics, Hotjar), \
                social media trackers (Facebook Pixel, TikTok), and device \
                manufacturer telemetry (Samsung, Xiaomi, Apple).
                """)

                Text("License: GPLv3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: PreviewData.makeIdleViewModel())
    }
}
