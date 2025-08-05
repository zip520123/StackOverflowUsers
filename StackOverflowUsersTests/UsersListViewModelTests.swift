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
        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        let exp = expectation(description: "Users updated")
        sut.onUsersUpdated = {
            exp.fulfill()
        }
        sut.fetchUsers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.users.count, 1)
        XCTAssertEqual(sut.users[0].display_name, "Test")
        
        trackForMemoryLeaks(sut)
    }

    func testFetchUsersFailure() {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        mockNetwork.result = .failure(NSError(domain: "Test", code: 1))
        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        let exp = expectation(description: "Error")
        sut.onError = { error in
            exp.fulfill()
        }
        sut.fetchUsers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.users.count, 0)
        trackForMemoryLeaks(sut)
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
        trackForMemoryLeaks(sut)
    }
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
