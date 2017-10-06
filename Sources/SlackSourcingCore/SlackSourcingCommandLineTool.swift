import Foundation
import Starscream

public final class SlackSourcingCommandLineTool {
    private let arguments: [String]
    private var socket: WebSocket!
    private var listener: SlackListener!

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        ProductionSlackClient().rtmConnect() { response in
            if response.ok {
                StandardSlackBot.shared.userId = response.myself.id
                StandardSlackBot.shared.userName = response.myself.name

                self.listener = SlackListener()
                self.socket = WebSocket(url: response.url)
                self.socket.delegate = self.listener
                print("Connecting to Slack RTM service on \(response.url)")
                self.socket.connect()
            } else {
                print("Slack RTM connection was denied. (Got a return object but `ok` was false)")
            }
        }
    }
}
