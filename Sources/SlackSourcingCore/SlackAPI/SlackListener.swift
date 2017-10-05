import Foundation
import Starscream

public class SlackListener: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocketClient) {
        print("Connected to Slack API. 🎯")
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconnected from Slack. 💔")
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Slack text: \(text)")
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Slack data: \(data)")
    }
}
