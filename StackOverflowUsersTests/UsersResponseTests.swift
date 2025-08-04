import XCTest
@testable import StackOverflowUsers

class UsersResponseTests: XCTestCase {
    func testUsersResponseDecoding() throws {
        let json = """
        {
            "items": [
                {
                    "user_id": 123,
                    "display_name": "Test User",
                    "reputation": 1000,
                    "profile_image": "https://example.com/image.png"
                },
                {
                    "user_id": 456,
                    "display_name": "Another User",
                    "reputation": 2000,
                    "profile_image": null
                }
            ]
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(UsersResponse.self, from: json)
        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.items[0].user_id, 123)
        XCTAssertEqual(response.items[0].display_name, "Test User")
        XCTAssertEqual(response.items[0].reputation, 1000)
        XCTAssertEqual(response.items[0].profile_image, "https://example.com/image.png")
        XCTAssertEqual(response.items[1].user_id, 456)
        XCTAssertEqual(response.items[1].display_name, "Another User")
        XCTAssertEqual(response.items[1].reputation, 2000)
        XCTAssertNil(response.items[1].profile_image)
    }
}
