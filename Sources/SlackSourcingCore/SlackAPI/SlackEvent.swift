import Foundation

public enum SlackEventTypeIdentifier: String, Codable {
    case hello
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

public class SlackEvent {
    public static func parse(json: String) throws -> BasicSlackEvent? {
        guard let data = json.data(using: .utf8) else {
            throw SlackParserError.unparseableData
        }

        let decoder = JSONDecoder()

        do {
            let untypedEvent = try decoder.decode(UntypedSlackEvent.self, from: data)
            return untypedEvent
        } catch {
            return nil
        }
    }
}
