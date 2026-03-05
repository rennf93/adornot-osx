import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: TestViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showClearConfirmation = false
    @State private var showAbout = false
    @State private var availableWidth: CGFloat = 500
    @Environment(\.uiScale) private var uiScale

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
                    PiholeSettingsSection(viewModel: viewModel)
                    dataManagementSection
                    aboutSection
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.vertical, Theme.spacingMD)
                .frame(maxWidth: 900 * uiScale)
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
            AboutView()
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            SectionHeader(title: "Test Categories", icon: "eye")

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
                    .font(Theme.scaledCaption(uiScale))
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
                        .frame(width: Theme.scaled(Theme.iconContainerMD, by: uiScale), height: Theme.scaled(Theme.iconContainerMD, by: uiScale))

                    Image(systemName: category.systemImage)
                        .font(Theme.fontIconMD(uiScale))
                        .foregroundStyle(isSelected ? Theme.brandBlueLight : .white.opacity(0.4))
                }

                Text(category.rawValue)
                    .font(Theme.scaledSubheadline(uiScale).weight(.medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(DomainRegistry.domains(for: category).count) domains")
                    .font(Theme.scaledCaption2(uiScale))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingMD)
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(Theme.scaledCaption(uiScale))
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
            SectionHeader(title: "Configuration", icon: "slider.horizontal.3")

            VStack(spacing: 0) {
                // Timeout setting
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    HStack {
                        Text("Request Timeout")
                            .font(Theme.scaledSubheadline(uiScale).weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(viewModel.requestTimeout))s")
                            .font(Theme.scaledSubheadline(uiScale).monospacedDigit())
                            .foregroundStyle(Theme.brandBlueLight)
                    }

                    Slider(value: $viewModel.requestTimeout, in: 3...15, step: 1)
                        .tint(Theme.brandBlue)

                    Text("How long to wait for each domain before marking it as blocked")
                        .font(Theme.scaledCaption2(uiScale))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(Theme.spacingMD)

                StyledDivider()

                // Export format
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Export Format")
                            .font(Theme.scaledSubheadline(uiScale).weight(.medium))
                            .foregroundStyle(.white)
                        Text("Default format when sharing results")
                            .font(Theme.scaledCaption2(uiScale))
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

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            SectionHeader(title: "Data Management", icon: "externaldrive")

            Button {
                showClearConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All History")
                    Spacer()
                }
                .font(Theme.scaledSubheadline(uiScale).weight(.medium))
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
            SectionHeader(title: "About", icon: "info.circle")

            Button {
                showAbout = true
            } label: {
                HStack(spacing: Theme.spacingMD) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Theme.scaled(Theme.logoSizeSM, by: uiScale), height: Theme.scaled(Theme.logoSizeSM, by: uiScale))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))

                    VStack(alignment: .leading, spacing: Theme.spacingXXS) {
                        Text("AdOrNot")
                            .font(Theme.scaledHeadline(uiScale))
                            .foregroundStyle(.white)
                        Text("Version \(AppVersion.current)")
                            .font(Theme.scaledCaption(uiScale))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("\(DomainRegistry.allDomains.count) domains in database")
                            .font(Theme.scaledCaption2(uiScale))
                            .foregroundStyle(.white.opacity(0.35))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(Theme.scaledCaption(uiScale).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .buttonStyle(.plain)
            .glassCard(padding: Theme.spacingMD)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: PreviewData.makeIdleViewModel())
    }
}
