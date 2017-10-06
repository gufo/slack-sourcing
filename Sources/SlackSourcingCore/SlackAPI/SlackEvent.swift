import Foundation

public enum SlackEventTypeIdentifier: String, Codable {
    case hello
    case message
}

public enum SlackParserError: Error {
    case unparseableData
}

public protocol BasicSlackEvent: Decodable {
    var type: SlackEventTypeIdentifier { get }
}

public struct UntypedSlackEvent: BasicSlackEvent {
    public var type: SlackEventTypeIdentifier
}

public struct SlackMessageEvent: BasicSlackEvent, Equatable {
    public var type: SlackEventTypeIdentifier
    public var channel: String
    public var user: String
    public var text: String
    public var timestamp: String

    enum CodingKeys: CodingKey, String {
        case type
        case channel
        case user
        case text
        case timestamp = "ts"
    }

    public init(type: SlackEventTypeIdentifier, channel: String, user: String, text: String, timestamp: String) {
        self.type = type
        self.channel = channel
        self.user = user
        self.text = text
        self.timestamp = timestamp
    }

    public func mentions(_ userId: String) -> Bool {
        return text.contains("<@\(userId)>")
    }

    public static func ==(lhs: SlackMessageEvent, rhs: SlackMessageEvent) -> Bool {
        return (
            lhs.type == rhs.type &&
            lhs.channel == rhs.channel &&
            lhs.user == rhs.user &&
            lhs.text == rhs.text &&
            lhs.timestamp == rhs.timestamp
        )
    }
}

public class SlackEvent {
    public static func parse(json: String) throws -> BasicSlackEvent? {
        guard let data = json.data(using: .utf8) else {
            throw SlackParserError.unparseableData
        }

        let decoder = JSONDecoder()

        do {
            let untypedEvent = try decoder.decode(UntypedSlackEvent.self, from: data)
            
            switch untypedEvent.type {
            case .hello: return untypedEvent
            case .message: return try decoder.decode(SlackMessageEvent.self, from: data)
            }
        } catch {
            return nil
        }
    }
}
