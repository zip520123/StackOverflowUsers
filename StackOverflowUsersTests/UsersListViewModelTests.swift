import XCTest
@testable import StackOverflowUsers

class MockNetworkService: NetworkServiceProtocol {
    private(set) var requests: [(Result<[User], Error>) -> Void] = []
    func fetchTopUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        requests.append(completion)
    }
}

class MockFollowManager: FollowManagerProtocol {
    var followed: Set<Int> = []
    var followedUserIds: [Int] { Array(followed) }
    func isFollowing(userId: Int) -> Bool { followed.contains(userId) }
    func follow(userId: Int) { followed.insert(userId) }
    func unfollow(userId: Int) { followed.remove(userId) }
}

class UsersListViewModelTests: XCTestCase {
    
    class Delegate: UsersListViewModelDelegate {
        private(set) var didUpdateUsersCallCounts = 0
        private(set) var didFailWithErrorCallCounts = 0
        func didUpdateUsers() { didUpdateUsersCallCounts += 1 }
        func didFailWithError(_ error: Error) { didFailWithErrorCallCounts += 1 }
    }
    
    
    func testFetchUsersSuccess() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        let user = User(user_id: 1, display_name: "Test", reputation: 100, profile_image: nil)

        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)

        
        let delegate = Delegate()
        sut.delegate = delegate
        XCTAssertEqual(mockNetwork.requests.count, 0)
        sut.fetchUsers()
        XCTAssertEqual(mockNetwork.requests.count, 1)
        
        XCTAssertEqual(delegate.didUpdateUsersCallCounts, 0)
        mockNetwork.requests[0](.success([user]))
        XCTAssertEqual(delegate.didUpdateUsersCallCounts, 1)
        
        XCTAssertEqual(sut.users.count, 1)
        XCTAssertEqual(sut.users[0].display_name, "Test")
    }

    func testFetchUsersFailure() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()

        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)

        let delegate = Delegate()
        sut.delegate = delegate
        XCTAssertEqual(mockNetwork.requests.count, 0)
        sut.fetchUsers()
        XCTAssertEqual(mockNetwork.requests.count, 1)
        
        XCTAssertEqual(delegate.didFailWithErrorCallCounts, 0)
        mockNetwork.requests[0](.failure(NSError(domain: "", code: 0)))
        XCTAssertEqual(delegate.didFailWithErrorCallCounts, 1)
        
        XCTAssertEqual(sut.users.count, 0)
    }

    func testFollowUnfollow() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        let user = User(user_id: 1, display_name: "Test", reputation: 100, profile_image: nil)
        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        
        XCTAssertFalse(sut.isFollowing(user: user))
        sut.follow(user: user)
        XCTAssertTrue(sut.isFollowing(user: user))
        sut.unfollow(user: user)
        XCTAssertFalse(sut.isFollowing(user: user))
    }
}
