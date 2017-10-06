import SlackSourcingCore
import XCTest

public class SlackBotTests: XCTestCase {
    func testIgnoresMessagesWithNoMentions() {
        let slackClient: DummySlackClient = DummySlackClient()
        let bot: StandardSlackBot = StandardSlackBot(slackClient: slackClient)

        bot.see(message: SlackMessageEvent(
            type: .message,
            channel: "A_CHANNEL",
            user: "A_USER",
            text: "hello",
            timestamp: ""
        ))

        XCTAssertEqual(slackClient.postedMessages, [])
    }
    
    func testMentionsTriggerSurprisedResponse() {
        let slackClient: DummySlackClient = DummySlackClient()
        let bot: StandardSlackBot = StandardSlackBot(slackClient: slackClient)
        bot.userId = "BOT_ID"

        bot.see(message: SlackMessageEvent(
            type: .message,
            channel: "A_CHANNEL",
            user: "A_USER",
            text: "<@BOT_ID> hello",
            timestamp: ""
        ))

        XCTAssertEqual(
            slackClient.postedMessages,
            ["A_CHANNEL <@A_USER> You talkin' to me? 'Cause I don't see nobody else here."]
        )
    }
}

class DummySlackClient: SlackClient {
    var postedMessages: [String] = []

    func rtmConnect(_ completionHandler: @escaping (SlackRTMConnectResponse) -> Void) {
        XCTFail("This dummy client does not support rtmConnect()")
    }

    func postMessage(_ text: String, to channel: String) {
        postedMessages.append("\(channel) \(text)")
    }
}
