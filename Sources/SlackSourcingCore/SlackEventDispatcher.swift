import Foundation

public class SlackEventDispatcher {
    private let bot: SlackBot
    
    public init(bot: SlackBot = StandardSlackBot.shared) {
        self.bot = bot
    }

    public func dispatch(_ event: BasicSlackEvent) {
        if let message = event as? SlackMessageEvent {
            bot.see(message: message)
        }
    }
}
