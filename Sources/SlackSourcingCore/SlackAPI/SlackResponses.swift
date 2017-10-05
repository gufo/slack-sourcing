import Foundation

public struct SlackRTMConnectResponse: Decodable {
    let ok: Bool
    let url: URL
}
