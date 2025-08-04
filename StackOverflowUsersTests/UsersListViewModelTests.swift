import XCTest
@testable import StackOverflowUsers

class MockNetworkService: NetworkServiceProtocol {
    var result: Result<[User], Error>?
    func fetchTopUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        if let result = result {
            completion(result)
        }
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
        let exp: XCTestExpectation
        init(exp: XCTestExpectation) { self.exp = exp }
        func didUpdateUsers() { exp.fulfill() }
        func didFailWithError(_ error: Error) { XCTFail() }
    }
    
    
    func testFetchUsersSuccess() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        let user = User(user_id: 1, display_name: "Test", reputation: 100, profile_image: nil)
        mockNetwork.result = .success([user])
        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        let exp = expectation(description: "Users updated")

        let delegate = Delegate(exp: exp)
        sut.delegate = delegate
        sut.fetchUsers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.users.count, 1)
        XCTAssertEqual(sut.users[0].display_name, "Test")
    }

    func testFetchUsersFailure() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        mockNetwork.result = .failure(NSError(domain: "Test", code: 1))
        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        let exp = expectation(description: "Error")

        let delegate = Delegate(exp: exp)
        sut.delegate = delegate
        sut.fetchUsers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.users.count, 0)
    }

    func testFollowUnfollow() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        let user = User(user_id: 1, display_name: "Test", reputation: 100, profile_image: nil)
        mockNetwork.result = .success([user])
        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        
        XCTAssertFalse(sut.isFollowing(user: user))
        sut.follow(user: user)
        XCTAssertTrue(sut.isFollowing(user: user))
        sut.unfollow(user: user)
        XCTAssertFalse(sut.isFollowing(user: user))
    }
}
