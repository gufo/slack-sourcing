import Alamofire
import Foundation

public protocol SlackClient {
    func rtmConnect(_ completionHandler: @escaping (SlackRTMConnectResponse) -> Void)
    func postMessage(_ text: String, to channel: String)
}

public class ProductionSlackClient: SlackClient {
    public static var shared: ProductionSlackClient = ProductionSlackClient()

    public func rtmConnect(_ completionHandler: @escaping (SlackRTMConnectResponse) -> Void) {
        let request = Alamofire.request(
            "https://slack.com/api/rtm.connect?token=\(SlackCredentials.botAccessToken)"
        )

        request.responseData { response in
            if let data = response.result.value {
                do {
                    let parsedResponse = try JSONDecoder().decode(SlackRTMConnectResponse.self, from: data)
                    completionHandler(parsedResponse)
                } catch {
                    print(error)
                }
            } else {
                print("Tried to request an RTM connection but got nothing.")
            }
        }
    }

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
