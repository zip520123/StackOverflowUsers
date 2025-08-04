import Foundation

protocol FollowManagerProtocol {
    func isFollowing(userId: Int) -> Bool
    func follow(userId: Int)
    func unfollow(userId: Int)
    var followedUserIds: [Int] { get }
}

class UserDefaultsFollowManager: FollowManagerProtocol {
    private let key = "followedUserIds"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var followedUserIds: [Int] {
        userDefaults.array(forKey: key) as? [Int] ?? []
    }
    
    func isFollowing(userId: Int) -> Bool {
        followedUserIds.contains(userId)
    }
    
    func follow(userId: Int) {
        var ids = followedUserIds
        if !ids.contains(userId) {
            ids.append(userId)
            userDefaults.set(ids, forKey: key)
        }
    }
    
    func unfollow(userId: Int) {
        var ids = followedUserIds
        if let index = ids.firstIndex(of: userId) {
            ids.remove(at: index)
            userDefaults.set(ids, forKey: key)
        }
    }
}
