import SlackSourcingCore
import XCTest

public class SlackBotTests: XCTestCase {
    func testIgnoresMessagesWithNoMentions() {
        let slackClient: DummySlackClient = DummySlackClient()
        let bot: StandardSlackBot = StandardSlackBot(slackClient: slackClient, sourcingClient: DummySourcingClient())

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
        let bot: StandardSlackBot = StandardSlackBot(slackClient: slackClient, sourcingClient: DummySourcingClient())
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

    func testAskingForTotalNumberOfActiveCases() {
        let slackClient: DummySlackClient = DummySlackClient()
        let sourcingClient: DummySourcingClient = DummySourcingClient()

        let bot = StandardSlackBot(slackClient: slackClient, sourcingClient: sourcingClient)
        bot.userId = "bot"
        
        bot.see(message: askBot("äre möcke nu?"))

        XCTAssertEqual(
            slackClient.postedMessages,
            ["CHANNEL <@curious> Vi har just nu 101 öppna ärenden."]
        )
    }

    func testAskingForMyOwnActiveClients() {
        let slackClient = DummySlackClient()
        let sourcingClient = DummySourcingClient()
        sourcingClient.prospectiveClients = ["Handelsbanken", "SVT", "TV4"]

        let bot = StandardSlackBot(slackClient: slackClient, sourcingClient: sourcingClient)
        bot.userId = "bot"

        bot.see(message: askBot("vilka kunder finns jag på?"))

        XCTAssertEqual(
            slackClient.postedMessages,
            ["CHANNEL <@curious> Du är aktuell hos Handelsbanken, SVT och TV4."]
        )
    }

    func testAskingForMyOwnActiveClientsWithDisappointingNews() {
        let slackClient = DummySlackClient()
        let sourcingClient = DummySourcingClient()
        sourcingClient.prospectiveClients = []

        let bot = StandardSlackBot(slackClient: slackClient, sourcingClient: sourcingClient)
        bot.userId = "bot"

        bot.see(message: askBot("vilka kunder finns jag på?"))

        XCTAssertEqual(
            slackClient.postedMessages,
            ["CHANNEL <@curious> Du är inte aktuell någonstans just nu. :broken_heart:"]
        )
    }

    private func askBot(_ question: String) -> SlackMessageEvent {
        return SlackMessageEvent(
            type: .message,
            channel: "CHANNEL",
            user: "curious",
            text: "<@bot> \(question)",
            timestamp: ""
        )
    }
}

class DummySlackClient: SlackClient {
    var postedMessages: [String] = []

    func getUser(_ userId: String, completion: @escaping (SlackUser?, Error?) -> Void) {
        let dummyUser = SlackUser(id: "12345", email: "example@valtech.se")
        completion(dummyUser, nil)
    }

    func rtmConnect(_ completionHandler: @escaping (SlackRTMConnectResponse) -> Void) {
        XCTFail("This dummy client does not support rtmConnect()")
    }

    func postMessage(_ text: String, to channel: String) {
        postedMessages.append("\(channel) \(text)")
    }
}

class DummySourcingClient: SourcingClient {
    var prospectiveClients: [String] = []

    func getProspectiveClientsForUser(_ email: String, completion: @escaping ([String]?, Error?) -> Void) {
        completion(prospectiveClients, nil)
    }

    func numberOfOpenCases(completion: @escaping (Int?, Error?) -> Void) {
        completion(101, nil)
    }
}
