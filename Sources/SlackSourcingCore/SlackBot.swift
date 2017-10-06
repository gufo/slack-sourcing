import Foundation

public protocol SlackBot {
    var userId: String { get set }
    var userName: String { get set }

    func see(message: SlackMessageEvent)
}

public class StandardSlackBot: SlackBot {
    public static var shared: SlackBot = StandardSlackBot()

    public var userId: String = ""
    public var userName: String = ""

    private var slackClient: SlackClient

    public init(slackClient: SlackClient = ProductionSlackClient.shared) {
        self.slackClient = slackClient
    }

    public func see(message: SlackMessageEvent) {
        if message.mentions(self.userId) {
            slackClient.postMessage("<@\(message.user)> You talkin' to me? 'Cause I don't see nobody else here.", to: message.channel)
        }
    }
}
