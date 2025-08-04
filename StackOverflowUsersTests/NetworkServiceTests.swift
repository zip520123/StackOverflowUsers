import XCTest
@testable import StackOverflowUsers

class MockURLSession: URLSession {
    var data: Data?
    var error: Error?
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, nil, self.error)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    init(closure: @escaping () -> Void) { self.closure = closure }
    override func resume() { closure() }
}

class NetworkServiceTests: XCTestCase {
    func testFetchTopUsersSuccess() {
        let mockSession = MockURLSession()
        let json = """
        { "items": [ { "user_id": 1, "display_name": "Test", "reputation": 100, "profile_image": null } ] }
        """.data(using: .utf8)!
        mockSession.data = json
        let sut = NetworkService(session: mockSession)
        let expectation = self.expectation(description: "Success")
        sut.fetchTopUsers { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users[0].user_id, 1)
                XCTAssertEqual(users[0].display_name, "Test")
                XCTAssertEqual(users[0].reputation, 100)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetchTopUsersFailure() {
        let mockSession = MockURLSession()
        mockSession.error = NSError(domain: "Test", code: 1)
        let sut = NetworkService(session: mockSession)
        let expectation = self.expectation(description: "Failure")
        sut.fetchTopUsers { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
