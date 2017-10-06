import Foundation
import SlackSourcingCore
import XCTest

public class SlackEventDispatcherTests: XCTestCase {
    class DummySlackBot: SlackBot {
        var userId: String = "BOT_ID"
        var userName: String = "Sourcing"
        var seenMessages: [SlackMessageEvent] = []

        func see(message: SlackMessageEvent) {
            seenMessages.append(message)
        }
    }

    func testSlackMessagesArePassedToBot() throws {
        let dummyBot = DummySlackBot()
        let dispatcher = SlackEventDispatcher(bot: dummyBot)

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

        dispatcher.dispatch(message)
        XCTAssertEqual(dummyBot.seenMessages, [message])
    }
}
