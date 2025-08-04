import Foundation

class MockNetworkService: NetworkServiceProtocol {
    var users: [User] = [User(user_id: 1, display_name: "Nick", reputation: 10, profile_image: nil),
                         User(user_id: 2, display_name: "Dick", reputation: 20, profile_image: nil),
                         User(user_id: 3, display_name: "Jack", reputation: 100, profile_image: nil)
    ]
    
    func fetchTopUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        completion(.success(users))
    }
}
