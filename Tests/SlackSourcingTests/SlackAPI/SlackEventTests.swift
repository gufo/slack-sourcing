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

    func testParsingChannelMessage() throws {
        let raw = """
            {
                "type": "message",
                "channel": "C2147483705",
                "user": "U2147483697",
                "text": "Hello world",
                "ts": "1355517523.000005"
            }
        """
        let message = try SlackEvent.parse(json: raw) as! SlackMessageEvent

        XCTAssertEqual(message.type, .message)
        XCTAssertEqual(message.channel, "C2147483705")
        XCTAssertEqual(message.user, "U2147483697")
        XCTAssertEqual(message.text, "Hello world")
        XCTAssertEqual(message.timestamp, "1355517523.000005")
    }
}
