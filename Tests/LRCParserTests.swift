import Testing
import Foundation
@testable import FreetifyCore

@Suite("Freetify LRC Parser Tests")
struct LRCParserTests {
    @Test("Parse standard [mm:ss.xx] timestamps")
    func testStandardLRCParse() {
        let sampleLRC = """
        [00:06.00]Dari jendela ku menatap langit kelabu
        [00:12.50]Bayangmu perlahan datang mengetuk kalbu
        [01:05.123]Haruskah kita mengulang kisah lama?
        """

        let lines = LRCParser.parse(sampleLRC)

        #expect(lines.count == 3)
        #expect(lines[0].time == 6.0)
        #expect(lines[0].text == "Dari jendela ku menatap langit kelabu")
        #expect(lines[1].time == 12.5)
        #expect(lines[2].time == 65.123)
    }

    @Test("Sort lines chronologically")
    func testOutOfOrderLRC() {
        let unorderedLRC = """
        [00:20.00]Line Two
        [00:10.00]Line One
        """

        let lines = LRCParser.parse(unorderedLRC)
        #expect(lines.count == 2)
        #expect(lines[0].text == "Line One")
        #expect(lines[1].text == "Line Two")
    }
}
