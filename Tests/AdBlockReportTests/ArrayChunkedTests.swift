import Testing
@testable import AdBlockReport

@Test func chunkedSplitsEvenly() {
    let array = [1, 2, 3, 4, 5, 6]
    let chunks = array.chunked(into: 2)
    #expect(chunks == [[1, 2], [3, 4], [5, 6]])
}

@Test func chunkedHandlesRemainder() {
    let array = [1, 2, 3, 4, 5]
    let chunks = array.chunked(into: 2)
    #expect(chunks == [[1, 2], [3, 4], [5]])
}

@Test func chunkedHandlesEmpty() {
    let array: [Int] = []
    let chunks = array.chunked(into: 3)
    #expect(chunks.isEmpty)
}

@Test func chunkedSizeLargerThanArray() {
    let array = [1, 2]
    let chunks = array.chunked(into: 10)
    #expect(chunks == [[1, 2]])
}
