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
        let user = User(user_id: 1, display_name: "Test", reputation: 100, profile_image: nil)
        let (sut, _, _) = makeSUT(networkResult: .success([user]))
        let exp = expectation(description: "Users updated")
        sut.onUsersUpdated = {
            exp.fulfill()
        }
        sut.fetchUsers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.users.count, 1)
        XCTAssertEqual(sut.users[0].display_name, "Test")
    }

    func testFetchUsersFailure() {
        let (sut, _, _) = makeSUT(networkResult: .failure(NSError(domain: "Test", code: 1)))
        let exp = expectation(description: "Error")
        sut.onError = { error in
            exp.fulfill()
        }
        sut.fetchUsers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.users.count, 0)
    }

    func testFollowUnfollow() {
        let (sut, _, _) = makeSUT()
        let user = User(user_id: 1, display_name: "Test", reputation: 100, profile_image: nil)

        XCTAssertFalse(sut.isFollowing(user: user))
        sut.follow(user: user)
        XCTAssertTrue(sut.isFollowing(user: user))
        sut.unfollow(user: user)
        XCTAssertFalse(sut.isFollowing(user: user))
    }
    
    func makeSUT(networkResult: Result<[User], Error>? = nil, file: StaticString = #filePath, line: UInt = #line) -> (sut: UsersListViewModel, mockNetwork: MockNetworkService, mockFollow: MockFollowManager) {
        let mockNetwork = MockNetworkService()
        let mockFollow = MockFollowManager()
        mockNetwork.result = networkResult
        let sut = UsersListViewModel(networkService: mockNetwork, followManager: mockFollow)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(mockNetwork, file: file, line: line)
        trackForMemoryLeaks(mockFollow, file: file, line: line)
        return (sut, mockNetwork, mockFollow)
    }
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
