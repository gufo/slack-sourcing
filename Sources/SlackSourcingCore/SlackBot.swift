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
    private var sourcingClient: SourcingClient

    public init(slackClient: SlackClient = ProductionSlackClient.shared, sourcingClient: SourcingClient = ProductionSourcingClient.shared) {
        self.slackClient = slackClient
        self.sourcingClient = sourcingClient
    }

    public func see(message: SlackMessageEvent) {
        if message.mentions(self.userId) {
            switch (message.inferredCommand()) {
            case .getTotalCount: reportNumberOfOpenCases(message: message)
            case .unknown:
                slackClient.postMessage("<@\(message.user)> You talkin' to me? 'Cause I don't see nobody else here.", to: message.channel)
            }
        }
    }

    public func reportNumberOfOpenCases(message: SlackMessageEvent) {
        sourcingClient.numberOfOpenCases() { count, error in
            guard let count = count else {
                return self.reportError(error, message: message)
            }

            self.slackClient.postMessage("<@\(message.user)> Vi har just nu \(count) öppna ärenden.", to: message.channel)
        }
    }

    public func reportError(_ error: Error?, message: SlackMessageEvent) {
        let description = error?.localizedDescription ?? "Gah! Jag kraschade och vet inte varför."
        self.slackClient.postMessage("<@\(message.user)> :face_with_head_bandage: \(description)", to: message.channel)
    }
}
