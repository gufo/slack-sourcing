import Foundation

class SourcingCase: Decodable {
    var id: String
    var isArchived: Bool
    var customer: String
    var suggestedConsultants: [String]
    var proposedConsultants: [String]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isArchived
        case customer
        case suggestedConsultants
        case proposedConsultants
    }

    func containsConsultant(_ consultant: SourcingConsultant) -> Bool {
        return suggestedConsultants.contains(consultant.id) || proposedConsultants.contains(consultant.id)
    }
}
