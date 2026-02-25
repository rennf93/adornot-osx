import SwiftUI

struct DomainsView: View {
    @State private var grouping: DomainGrouping = .byCategory
    @State private var searchText = ""
    @State private var expandedSections: Set<String> = []
    @State private var availableWidth: CGFloat = 600

    @Environment(\.openURL) private var openURL

    private enum DomainGrouping: String, CaseIterable {
        case byCategory = "By Category"
        case byProvider = "By Provider"
    }

    // MARK: - Filtered Data

    private var filteredDomains: [TestDomain] {
        guard !searchText.isEmpty else { return DomainRegistry.allDomains }
        let query = searchText.lowercased()
        return DomainRegistry.allDomains.filter {
            $0.hostname.lowercased().contains(query)
            || $0.provider.lowercased().contains(query)
        }
    }

    private var filteredBlocklists: [BlocklistEntry] {
        guard !searchText.isEmpty else { return BlocklistRegistry.allLists }
        let query = searchText.lowercased()
        return BlocklistRegistry.allLists.filter {
            $0.name.lowercased().contains(query)
            || $0.author.lowercased().contains(query)
            || $0.description.lowercased().contains(query)
        }
    }

    private var blocklistColumnCount: Int {
        Theme.responsiveColumnCount(
            availableWidth: availableWidth,
            minColumns: 1,
            idealItemWidth: 320
        )
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    statsRow
                    groupingPicker
                    domainsSection
                    blocklistsSection
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.vertical, Theme.spacingMD)
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newWidth in
                    availableWidth = newWidth
                }
            }
        }
        .navigationTitle("Domains")
        .searchable(text: $searchText, prompt: "Search domains or blocklists")
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: Theme.spacingMD) {
            StatCard(
                title: "Domains",
                value: "\(DomainRegistry.allDomains.count)",
                icon: "globe"
            )
            StatCard(
                title: "Providers",
                value: "\(DomainRegistry.providers.count)",
                icon: "building.2"
            )
            StatCard(
                title: "Blocklists",
                value: "\(BlocklistRegistry.allLists.count)",
                icon: "list.bullet.rectangle"
            )
        }
    }

    // MARK: - Grouping Picker

    private var groupingPicker: some View {
        Picker("", selection: $grouping) {
            ForEach(DomainGrouping.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 260)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Domains Section

    private var domainsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader(title: "Test Domains", icon: "globe")

            switch grouping {
            case .byCategory:
                categorySections
            case .byProvider:
                providerSections
            }
        }
    }

    // MARK: - By Category

    private var categorySections: some View {
        ForEach(TestCategory.standardCases, id: \.self) { category in
            let domains = filteredDomains.filter { $0.category == category }
            if !domains.isEmpty {
                expandableSection(
                    key: category.rawValue,
                    icon: category.systemImage,
                    title: category.rawValue,
                    subtitle: "\(domains.count) domains",
                    linkURL: nil
                ) {
                    ForEach(domains, id: \.hostname) { domain in
                        domainRow(domain)
                    }
                }
            }
        }
    }

    // MARK: - By Provider

    private var providerSections: some View {
        let grouped = Dictionary(grouping: filteredDomains, by: \.provider)
        let sortedKeys = grouped.keys.sorted()

        return ForEach(sortedKeys, id: \.self) { provider in
            let domains = grouped[provider] ?? []
            let providerInfo = ProviderRegistry.info(for: provider)

            expandableSection(
                key: provider,
                icon: nil,
                title: provider,
                subtitle: "\(domains.count) domains",
                linkURL: providerInfo?.websiteURL
            ) {
                if let info = providerInfo {
                    Text(info.description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, Theme.spacingMD)
                        .padding(.top, Theme.spacingSM)
                }
                ForEach(domains, id: \.hostname) { domain in
                    domainRow(domain)
                }
            }
        }
    }

    // MARK: - Expandable Section

    private func expandableSection<Content: View>(
        key: String,
        icon: String?,
        title: String,
        subtitle: String,
        linkURL: URL?,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if expandedSections.contains(key) {
                        expandedSections.remove(key)
                    } else {
                        expandedSections.insert(key)
                    }
                }
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    if let icon {
                        ZStack {
                            RoundedRectangle(cornerRadius: Theme.radiusSM)
                                .fill(Theme.brandBlue.opacity(0.15))
                                .frame(width: 32, height: 32)

                            Image(systemName: icon)
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.brandBlueLight)
                        }
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer()

                    if let url = linkURL {
                        Button {
                            openURL(url)
                        } label: {
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(Theme.brandBlueLight)
                        }
                        .buttonStyle(.plain)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.3))
                        .rotationEffect(.degrees(expandedSections.contains(key) ? 90 : 0))
                }
                .padding(Theme.spacingMD)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expandedSections.contains(key) {
                VStack(spacing: 0) {
                    Divider()
                        .overlay(Color.white.opacity(0.06))

                    LazyVStack(spacing: 0) {
                        content()
                    }
                    .padding(.vertical, Theme.spacingSM)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .glassCard(padding: 0)
    }

    // MARK: - Domain Row

    private func domainRow(_ domain: TestDomain) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Text(domain.hostname)
                .font(.caption.monospaced())
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)

            Spacer()

            if grouping == .byCategory {
                Text(domain.provider)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }

            if grouping == .byProvider {
                categoryBadge(domain.category)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingXS + 2)
    }

    private func categoryBadge(_ category: TestCategory) -> some View {
        Text(category.rawValue)
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(Theme.brandBlueLight)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Theme.brandBlue.opacity(0.15))
            )
    }

    // MARK: - Blocklists Section

    private var blocklistsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader(title: "Recommended Blocklists", icon: "list.bullet.rectangle")

            if filteredBlocklists.isEmpty {
                Text("No blocklists match your search.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(Theme.spacingLG)
            } else {
                LazyVGrid(
                    columns: Theme.flexibleColumns(count: blocklistColumnCount),
                    spacing: Theme.spacingMD
                ) {
                    ForEach(filteredBlocklists) { entry in
                        blocklistCard(entry)
                    }
                }
            }
        }
    }

    private func blocklistCard(_ entry: BlocklistEntry) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("by \(entry.author)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }
                Spacer()
                Button {
                    openURL(entry.websiteURL)
                } label: {
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(Theme.brandBlueLight)
                }
                .buttonStyle(.plain)
            }

            Text(entry.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(3)

            HStack(spacing: 6) {
                Text(entry.category.rawValue)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Theme.brandBlueLight)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(Theme.brandBlue.opacity(0.15))
                    )

                Text(entry.format.rawValue)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(Color.white.opacity(0.08))
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: Theme.spacingMD)
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
}

#Preview {
    NavigationStack {
        DomainsView()
    }
}
