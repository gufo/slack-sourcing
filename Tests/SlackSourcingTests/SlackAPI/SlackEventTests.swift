import Foundation
import SlackSourcingCore
import XCTest

public class SlackEventTests: XCTestCase {
    func testHelloMessageReturnsGenericType() throws {
        let raw = """
            {"type": "hello"}
        """
        let message = try SlackEvent.parse(json: raw)!

        XCTAssertEqual(message.type, .hello)
    }

    func testUnknownMessageIsNotParsed() throws {
        let raw = """
            {"type": "bogusMessageType"}
        """
        let message = try SlackEvent.parse(json: raw)

        XCTAssertNil(message)
    }
}
