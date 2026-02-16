import Testing
import Foundation
import SwiftData
@testable import AdBlockReport

@Test @MainActor func viewModelStartsIdle() {
    let vm = TestViewModel(testService: nil, useNetworkMonitor: false)
    #expect(vm.state == .idle)
    #expect(vm.progress == 0)
    #expect(vm.results.isEmpty)
    #expect(vm.overallScore == 0)
}

@Test @MainActor func viewModelSelectedCategoriesDefaultToAll() {
    let vm = TestViewModel(testService: nil, useNetworkMonitor: false)
    #expect(vm.selectedCategories == Set(TestCategory.allCases))
}

@Test @MainActor func viewModelDomainsToTestReflectsSelectedCategories() {
    let vm = TestViewModel(testService: nil, useNetworkMonitor: false)
    vm.selectedCategories = [.ads]
    let domains = vm.domainsToTest
    #expect(domains.allSatisfy { $0.category == .ads })
    #expect(domains.count == DomainRegistry.domains(for: .ads).count)
}

@Test @MainActor func viewModelDomainsToTestEmptyWhenNoCategoriesSelected() {
    let vm = TestViewModel(testService: nil, useNetworkMonitor: false)
    vm.selectedCategories = []
    #expect(vm.domainsToTest.isEmpty)
}

@Test @MainActor func viewModelResetClearsState() {
    let vm = TestViewModel(testService: nil, useNetworkMonitor: false)
    vm.overallScore = 75.0
    vm.results = [TestResult(
        domain: TestDomain(hostname: "t.com", provider: "T", category: .ads),
        isBlocked: true
    )]
    vm.state = .completed

    vm.reset()

    #expect(vm.state == .idle)
    #expect(vm.results.isEmpty)
    #expect(vm.overallScore == 0)
    #expect(vm.categoryScores.isEmpty)
    #expect(vm.progress == 0)
    #expect(vm.completedCount == 0)
}

@Test @MainActor func viewModelGuardsAgainstDoubleStart() throws {
    let vm = TestViewModel(testService: nil, useNetworkMonitor: false)
    vm.state = .running

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: TestReport.self, configurations: config)
    let context = ModelContext(container)

    vm.startTest(modelContext: context)
    #expect(vm.state == .running)
}

@Test @MainActor func viewModelGuardsAgainstStartWhenNetworkUnavailable() throws {
    let vm = TestViewModel(testService: nil, useNetworkMonitor: false)
    vm.networkUnavailable = true

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: TestReport.self, configurations: config)
    let context = ModelContext(container)

    vm.startTest(modelContext: context)
    #expect(vm.state == .idle)
}

@Test @MainActor func viewModelResultsByCategoryGroupsCorrectly() {
    let vm = TestViewModel(testService: nil, useNetworkMonitor: false)
    vm.results = [
        TestResult(domain: TestDomain(hostname: "a1.com", provider: "P", category: .ads), isBlocked: true),
        TestResult(domain: TestDomain(hostname: "a2.com", provider: "P", category: .ads), isBlocked: false),
        TestResult(domain: TestDomain(hostname: "b1.com", provider: "P", category: .analytics), isBlocked: true),
    ]

    let grouped = vm.resultsByCategory
    #expect(grouped.count == 2)
    #expect(grouped[0].category == .ads)
    #expect(grouped[0].results.count == 2)
    #expect(grouped[1].category == .analytics)
    #expect(grouped[1].results.count == 1)
}
