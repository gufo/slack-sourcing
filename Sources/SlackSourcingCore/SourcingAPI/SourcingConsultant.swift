import Foundation

public class SourcingConsultant: Decodable {
    var id: String
    var name: String
    var email: String

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
    }
}
