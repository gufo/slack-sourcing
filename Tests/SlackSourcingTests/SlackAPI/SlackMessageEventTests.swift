import SlackSourcingCore
import XCTest

public class SlackMessageEventTests: XCTestCase {
    func testUserIsMentionedWhenPresentInMessageText() {
        let message = SlackMessageEvent(
            type: .message,
            channel: "A_CHANNEL",
            user: "SENDER",
            text: "Hello <@MENTION> how are you today? NON_MENTION @NON_MENTION @<NON_MENTION> <@NON_MENTION >",
            timestamp: ""
        )

        XCTAssertTrue(message.mentions("MENTION"))
        XCTAssertFalse(message.mentions("NON_MENTION"))
    }
}
