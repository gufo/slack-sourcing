import Foundation

class SourcingCase: Decodable {
    var id: String
    var isArchived: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isArchived
    }
}
