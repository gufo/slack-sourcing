import Foundation
import SlackSourcingCore
import XCTest

public class SlackMessageTests: XCTestCase {
    func testHelloMessageReturnsGenericType() throws {
        let raw = """
            {"type": "hello"}
        """
        let message = try SlackMessage.parse(json: raw)!

        XCTAssertEqual(message.type, .hello)
    }

    func testUnknownMessageIsNotParsed() throws {
        let raw = """
            {"type": "bogusMessageType"}
        """
        let message = try SlackMessage.parse(json: raw)

        XCTAssertNil(message)
    }
}
