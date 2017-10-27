import Foundation

// Format reference: https://api.slack.com/methods/users.info

public struct SlackUserResponse: Decodable {
    let ok: Bool
    let user: SlackUser
}

public struct SlackUser: Decodable {
    let id: String
    let profile: SlackUserProfile
    var email: String { return profile.email }

    struct SlackUserProfile: Decodable {
        let email: String
    }
}
