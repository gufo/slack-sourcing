import Foundation

public protocol SlackBot {
    func see(message: SlackMessageEvent)
}

public class StandardSlackBot: SlackBot {
    public static var shared: SlackBot = StandardSlackBot()

    public func see(message: SlackMessageEvent) {

    }
}
