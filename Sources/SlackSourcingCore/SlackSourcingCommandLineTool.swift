import Foundation
import Starscream
import OAuth

public final class SlackSourcingCommandLineTool {
    private let arguments: [String]
    private var socket: WebSocket!
    private var listener: SlackListener!
    private var urlSession: URLSession!
    private var oauthClient: OAuthClient!

    private let productionUrl = URL(string: "https://stage-sourcing.valtech.se/")!

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        ProductionSlackClient().rtmConnect() { response in
            if response.ok {
                self.urlSession = URLSession(configuration: .ephemeral)
                self.oauthClient = OAuthClient(url: self.productionUrl, session: self.urlSession)
                self.oauthClient.authenticate(username: SourcingCredentials.username, password: SourcingCredentials.password) { error in
                    guard error == nil else {
                        print("FATAL: OAuth authentication failed.")
                        exit(-1)
                    }
                }
                OAuthClient.shared = self.oauthClient
                ProductionSourcingClient.shared = ProductionSourcingClient(
                    url: ProductionSourcingClient.stagingURL,
                    oauthClient: OAuthClient.shared,
                    urlSession: self.urlSession
                )

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
