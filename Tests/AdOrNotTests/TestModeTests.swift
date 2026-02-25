import Testing
@testable import AdOrNot

@Test func testModeStandardValues() {
    let mode = TestMode.standard
    #expect(mode.rawValue == "Standard")
    #expect(mode.label == "Standard")
    #expect(mode.systemImage == "network")
    #expect(mode.id == "Standard")
}

@Test func testModePiholeValues() {
    let mode = TestMode.pihole
    #expect(mode.rawValue == "Pi-hole")
    #expect(mode.label == "Pi-hole")
    #expect(mode.systemImage == "shield.checkered")
    #expect(mode.id == "Pi-hole")
}

@Test func testModeAllCases() {
    #expect(TestMode.allCases.count == 2)
    #expect(TestMode.allCases.contains(.standard))
    #expect(TestMode.allCases.contains(.pihole))
}

@Test func testModeDescriptionsNotEmpty() {
    for mode in TestMode.allCases {
        #expect(!mode.description.isEmpty)
    }
}
