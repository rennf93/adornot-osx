import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: TestViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showClearConfirmation = false
    @State private var showAbout = false
    @State private var availableWidth: CGFloat = 500
    @State private var piholePassword: String = KeychainHelper.load(key: "piholePassword") ?? ""
    @State private var piholeConnectionStatus: PiholeConnectionStatus = .idle

    private enum PiholeConnectionStatus {
        case idle, testing, success, failure
    }

    private var categoryColumnCount: Int {
        Theme.responsiveColumnCount(
            availableWidth: availableWidth,
            minColumns: 2,
            idealItemWidth: 240
        )
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    categoriesSection
                    configurationSection
                    piholeSection
                    dataManagementSection
                    aboutSection
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.vertical, Theme.spacingMD)
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newWidth in
                    availableWidth = newWidth
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showAbout) {
            aboutDetailView
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader(title: "Test Categories", icon: "eye")

            LazyVGrid(
                columns: Theme.flexibleColumns(count: categoryColumnCount),
                spacing: Theme.spacingMD
            ) {
                ForEach(TestCategory.standardCases, id: \.self) { category in
                    categoryCard(category: category)
                }
            }

            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(Theme.brandBlueLight)
                Text("\(viewModel.domainsToTest.count) domains selected")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
            }
            .padding(.horizontal, Theme.spacingXS)
        }
    }

    private func categoryCard(category: TestCategory) -> some View {
        let isSelected = viewModel.selectedCategories.contains(category)

        return Button {
            if isSelected {
                if viewModel.selectedCategories.count > 1 {
                    viewModel.selectedCategories.remove(category)
                }
            } else {
                viewModel.selectedCategories.insert(category)
            }
        } label: {
            VStack(spacing: Theme.spacingSM) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(Theme.brandBlue.opacity(isSelected ? 0.25 : 0.10))
                        .frame(width: 40, height: 40)

                    Image(systemName: category.systemImage)
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected ? Theme.brandBlueLight : .white.opacity(0.4))
                }

                Text(category.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(DomainRegistry.domains(for: category).count) domains")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingMD)
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.brandBlueLight)
                        .padding(Theme.spacingSM)
                }
            }
        }
        .buttonStyle(.plain)
        .glassCard(padding: 0)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusLG)
                .strokeBorder(
                    isSelected ? Theme.brandBlue.opacity(0.4) : Color.clear,
                    lineWidth: 1.5
                )
        )
    }

    // MARK: - Configuration Section

    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader(title: "Configuration", icon: "slider.horizontal.3")

            VStack(spacing: 0) {
                // Timeout setting
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    HStack {
                        Text("Request Timeout")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(viewModel.requestTimeout))s")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(Theme.brandBlueLight)
                    }

                    Slider(value: $viewModel.requestTimeout, in: 3...15, step: 1)
                        .tint(Theme.brandBlue)

                    Text("How long to wait for each domain before marking it as blocked")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(Theme.spacingMD)

                Divider()
                    .overlay(Color.white.opacity(0.06))

                // Export format
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Export Format")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                        Text("Default format when sharing results")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    Spacer()
                    Picker("", selection: $viewModel.exportFormat) {
                        ForEach(ExportFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                }
                .padding(Theme.spacingMD)
            }
            .glassCard(padding: 0)
        }
    }

    // MARK: - Pi-hole Section

    private var piholeSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader(title: "Pi-hole", icon: "shield.checkered")

            VStack(spacing: 0) {
                // Host address
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("Host Address")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)

                    TextField("192.168.1.x", text: Binding(
                        get: { viewModel.piholeHost },
                        set: { viewModel.savePiholeHost($0) }
                    ))
                    .textFieldStyle(.roundedBorder)

                    Text("Just the IP address (e.g. 192.168.1.100) or with port (e.g. 192.168.1.100:8080)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(Theme.spacingMD)

                Divider()
                    .overlay(Color.white.opacity(0.06))

                // Password
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("Password")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)

                    SecureField("Pi-hole password", text: $piholePassword)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: piholePassword) { _, newValue in
                            if newValue.isEmpty {
                                KeychainHelper.delete(key: "piholePassword")
                            } else {
                                _ = KeychainHelper.save(key: "piholePassword", value: newValue)
                            }
                        }

                    Text("Stored securely in Keychain")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(Theme.spacingMD)

                Divider()
                    .overlay(Color.white.opacity(0.06))

                // Test connection button
                HStack {
                    Button {
                        piholeConnectionStatus = .testing
                        Task {
                            let success = await viewModel.testPiholeConnection()
                            piholeConnectionStatus = success ? .success : .failure
                        }
                    } label: {
                        HStack(spacing: Theme.spacingSM) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Test Connection")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.brandBlueLight)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.piholeHost.isEmpty || piholePassword.isEmpty)

                    Spacer()

                    switch piholeConnectionStatus {
                    case .idle:
                        EmptyView()
                    case .testing:
                        ProgressView()
                            .controlSize(.small)
                    case .success:
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Connected")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.scoreGood)
                    case .failure:
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Failed")
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.scoreWeak)

                            if let error = viewModel.piholeError {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.5))
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                .padding(Theme.spacingMD)
            }
            .glassCard(padding: 0)
        }
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader(title: "Data Management", icon: "externaldrive")

            Button {
                showClearConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All History")
                    Spacer()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.scoreWeak)
                .padding(Theme.spacingMD)
            }
            .buttonStyle(.plain)
            .glassCard(padding: 0)
            .confirmationDialog(
                "Clear All History?",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Reports", role: .destructive) {
                    do {
                        try modelContext.delete(model: TestReport.self)
                        try modelContext.save()
                    } catch {
                        // Silent failure — data deletion is best-effort
                    }
                }
            } message: {
                Text("This will permanently delete all saved test reports. This action cannot be undone.")
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader(title: "About", icon: "info.circle")

            Button {
                showAbout = true
            } label: {
                HStack(spacing: Theme.spacingMD) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AdOrNot")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Version \(AppVersion.current)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        Text("\(DomainRegistry.allDomains.count) domains in database")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.35))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .buttonStyle(.plain)
            .glassCard(padding: Theme.spacingMD)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Theme.brandBlueLight)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: - About Detail

    private var aboutDetailView: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    VStack(spacing: Theme.spacingMD) {
                        ZStack {
                            Circle()
                                .fill(Theme.brandBlue.opacity(0.15))
                                .frame(width: 100, height: 100)
                                .blur(radius: 15)

                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Text("AdOrNot")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, Theme.spacingLG)

                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        aboutParagraph(
                            title: nil,
                            text: "This app tests the effectiveness of your DNS-level ad blocker or content filter by attempting to reach known advertising, analytics, and tracking domains."
                        )

                        aboutParagraph(
                            title: "How It Works",
                            text: "For each domain in our curated list, the app sends an HTTP HEAD request. If the request fails because DNS resolution is blocked, the domain is counted as blocked. The percentage of blocked domains gives you a score indicating how effective your ad blocker is."
                        )

                        aboutParagraph(
                            title: "Domain Coverage",
                            text: "The domain list includes well-known ad networks (Google Ads, DoubleClick), analytics services (Google Analytics, Hotjar), social media trackers (Facebook Pixel, TikTok), and device manufacturer telemetry (Samsung, Xiaomi, Apple)."
                        )
                    }
                    .glassCard(padding: Theme.spacingMD)

                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundStyle(Theme.brandBlueLight)
                        Text("License: GPLv3")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                    }
                    .padding(.horizontal, Theme.spacingXS)
                }
                .padding(.horizontal, Theme.spacingLG)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 400, minHeight: 400)
    }

    private func aboutParagraph(title: String?, text: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Text(text)
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: PreviewData.makeIdleViewModel())
    }
}
