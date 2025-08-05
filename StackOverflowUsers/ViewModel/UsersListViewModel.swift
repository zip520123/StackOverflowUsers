import Foundation

class UsersListViewModel {
    private let networkService: NetworkServiceProtocol
    private let followManager: FollowManagerProtocol
    private(set) var users: [User] = []
    
    var isLoading: Bool = false
    
    var onUsersUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(networkService: NetworkServiceProtocol,
         followManager: FollowManagerProtocol) {
        self.networkService = networkService
        self.followManager = followManager
    }
    
    func fetchUsers() {
        isLoading = true
        networkService.fetchTopUsers { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let users):
                self.users = users
                self.onUsersUpdated?()
            case .failure(let error):
                self.users = []
                self.onError?(error)
            }
        }
    }
    
    func isFollowing(user: User) -> Bool {
        followManager.isFollowing(userId: user.user_id)
    }
    
    func follow(user: User) {
        followManager.follow(userId: user.user_id)
        onUsersUpdated?()
    }
    
    func unfollow(user: User) {
        followManager.unfollow(userId: user.user_id)
        onUsersUpdated?()
    }
}
