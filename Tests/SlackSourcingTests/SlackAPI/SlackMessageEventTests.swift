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

    func testInfersTotalCountCommands() {
        let message = build(message: "Är det möcke nu?")
        XCTAssertEqual(message.inferredCommand(), .getTotalCount)
    }

    func testInfersMyProspectiveClientsQuery() {
        var message = build(message: "Vilka kunder är jag inspelad mot?")
        XCTAssertEqual(message.inferredCommand(), .getMyProspectiveCustomers)

        message = build(message: "Har jag några kunder?")
        XCTAssertEqual(message.inferredCommand(), .getMyProspectiveCustomers)
    }

    private func build(message: String) -> SlackMessageEvent {
        return SlackMessageEvent(
            type: .message,
            channel: "channel",
            user: "sender",
            text: message,
            timestamp: ""
        )

    }
}
