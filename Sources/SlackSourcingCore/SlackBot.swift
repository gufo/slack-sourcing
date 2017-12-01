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
            case .getMyProspectiveCustomers: reportMyProspectiveClients(message: message)
            case .whoami: reportMyEmailAddress(message: message)
            case .unknown:
                slackClient.postMessage("<@\(message.user)> You talkin' to me? 'Cause I don't see nobody else here.", to: message.channel)
            }
        }
    }

    func reportNumberOfOpenCases(message: SlackMessageEvent) {
        sourcingClient.numberOfOpenCases() { count, error in
            guard let count = count else {
                return self.reportError(error, message: message)
            }

            self.slackClient.postMessage("<@\(message.user)> Vi har just nu \(count) öppna ärenden.", to: message.channel)
        }
    }

    func reportMyEmailAddress(message: SlackMessageEvent) {
        slackClient.getUser(message.user) { user, error in
            guard let user = user else {
                return self.reportError(error, message: message)
            }

            self.slackClient.postMessage("<@\(message.user)> Du är: \(user.email)", to: message.channel)
        }
    }

    func reportMyProspectiveClients(message: SlackMessageEvent) {
        slackClient.getUser(message.user) { user, error in
            guard let user = user else {
                return self.reportError(error, message: message)
            }

            self.sourcingClient.getProspectiveClientsForUser(user.email) { clients, error in
                guard let clients = clients else {
                    return self.reportError(error, message: message)
                }

                if clients.count > 0 {
                    self.slackClient.postMessage("<@\(message.user)> Du är aktuell hos \(self.join(clients)).", to: message.channel)
                } else {
                    self.slackClient.postMessage("<@\(message.user)> Du är inte aktuell någonstans just nu. :broken_heart:", to: message.channel)
                }
            }
        }
    }

    func reportError(_ error: Error?, message: SlackMessageEvent) {
        let description = error?.localizedDescription ?? "Gah! Jag kraschade och vet inte varför."
        self.slackClient.postMessage("<@\(message.user)> :face_with_head_bandage: \(description)", to: message.channel)
    }

    private func join(_ strings: [String]) -> String {
        if strings.count == 1 {
            return strings.first!
        } else {
            let most = strings[0...strings.count - 2]
            return most.joined(separator: ", ") + " och " + strings.last!
        }
    }
}
