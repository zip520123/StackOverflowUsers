import Foundation

struct UsersResponse: Codable {
    let items: [User]
}

struct User: Codable, Equatable {
    let user_id: Int
    let display_name: String
    let reputation: Int
    let profile_image: String?
}
