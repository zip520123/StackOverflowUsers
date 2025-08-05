import Foundation

protocol UsersListViewModelDelegate: AnyObject {
    func didUpdateUsers()
    func didFailWithError(_ error: Error)
}

class UsersListViewModel {
    private let networkService: NetworkServiceProtocol
    private let followManager: FollowManagerProtocol
    private(set) var users: [User] = []
    weak var delegate: UsersListViewModelDelegate?
    
    var isLoading: Bool = false
    var error: Error?
    
    init(networkService: NetworkServiceProtocol,
         followManager: FollowManagerProtocol) {
        self.networkService = networkService
        self.followManager = followManager
    }
    
    func fetchUsers() {
        isLoading = true
        networkService.fetchTopUsers { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let users):
                self?.users = users
                self?.delegate?.didUpdateUsers()
            case .failure(let error):
                self?.error = error
                self?.users = []
                self?.delegate?.didFailWithError(error)
            }
        }
    }
    
    func isFollowing(user: User) -> Bool {
        followManager.isFollowing(userId: user.user_id)
    }
    
    func follow(user: User) {
        followManager.follow(userId: user.user_id)
        delegate?.didUpdateUsers()
    }
    
    func unfollow(user: User) {
        followManager.unfollow(userId: user.user_id)
        delegate?.didUpdateUsers()
    }
}
