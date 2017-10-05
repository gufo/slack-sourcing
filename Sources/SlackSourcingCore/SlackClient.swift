import Alamofire

public protocol SlackClient {
    func postMessage(_ text: String, to channel: String)
}

public class ProductionSlackClient: SlackClient {
    public func postMessage(_ text: String, to channel: String) {
        Alamofire.request(
            "https://slack.com/api/chat.postMessage",
            method: .post,
            parameters: [
                "token": SlackCredentials.botAccessToken,
                "channel": channel,
                "text": text
            ]).responseString { response in
                print(response)
        }
    }
}
