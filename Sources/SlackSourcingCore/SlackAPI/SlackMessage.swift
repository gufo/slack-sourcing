import Foundation

public enum SlackMessageTypeIdentifier: String, Codable {
    case hello
}

public enum SlackParserError: Error {
    case unparseableData
}

public protocol BasicSlackMessage: Decodable {
    var type: SlackMessageTypeIdentifier { get }
}

public struct UntypedSlackMessage: BasicSlackMessage {
    public var type: SlackMessageTypeIdentifier
}

public class SlackMessage {
    public static func parse(json: String) throws -> BasicSlackMessage? {
        guard let data = json.data(using: .utf8) else {
            throw SlackParserError.unparseableData
        }

        let decoder = JSONDecoder()

        do {
            let untypedMessage = try decoder.decode(UntypedSlackMessage.self, from: data)
            return untypedMessage
        } catch {
            return nil
        }
    }
}
