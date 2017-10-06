import Foundation

public struct SlackRTMConnectResponse: Decodable {
    let ok: Bool
    let url: URL
    let myself: SlackSelf

    public enum CodingKeys: CodingKey, String {
        case ok
        case url
        case myself = "self"
    }
}

public struct SlackSelf: Decodable {
    let id: String
    let name: String
}
