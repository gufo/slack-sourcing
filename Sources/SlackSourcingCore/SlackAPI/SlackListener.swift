import Foundation
import Starscream

public class SlackListener: WebSocketDelegate {
    private var dispatcher: SlackEventDispatcher = SlackEventDispatcher()
    
    public func websocketDidConnect(socket: WebSocketClient) {
        print("Connected to Slack API. 🎯")
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconnected from Slack. 💔")
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Slack text: \(text)")
        do {
            if let event = try SlackEvent.parse(json: text) {
                self.dispatcher.dispatch(event)
            }
        } catch {
            print("Could not parse Slack event. Reason: \(error)")
        }
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Slack data: \(data)")
    }
}
