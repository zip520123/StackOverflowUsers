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
    func testFetchUsersSuccess() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        let user = User(user_id: 1, display_name: "Test", reputation: 100, profile_image: nil)
        mockNetwork.result = .success([user])
        let viewModel = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        let exp = expectation(description: "Users updated")
        viewModel.onUsersUpdated = {
            exp.fulfill()
        }
        viewModel.fetchUsers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(viewModel.users.count, 1)
        XCTAssertEqual(viewModel.users[0].display_name, "Test")
    }

    func testFetchUsersFailure() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        mockNetwork.result = .failure(NSError(domain: "Test", code: 1))
        let viewModel = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        let exp = expectation(description: "Error")
        viewModel.onError = { error in
            exp.fulfill()
        }
        viewModel.fetchUsers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(viewModel.users.count, 0)
    }

    func testFollowUnfollow() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        let user = User(user_id: 1, display_name: "Test", reputation: 100, profile_image: nil)
        let viewModel = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)

        XCTAssertFalse(viewModel.isFollowing(user: user))
        viewModel.follow(user: user)
        XCTAssertTrue(viewModel.isFollowing(user: user))
        viewModel.unfollow(user: user)
        XCTAssertFalse(viewModel.isFollowing(user: user))
    }
}
