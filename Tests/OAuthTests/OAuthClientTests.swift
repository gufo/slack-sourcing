import Foundation
import OAuth
import XCTest

public class OAuthClientTests: XCTestCase {
    private let testEnvironment = URL(string: "https://stage-sourcing.valtech.se/")!

    func testInvalidLoginResultsInError() {
        let client = OAuthClient(url: testEnvironment, session: URLSession(configuration: .ephemeral))
        let expectation = XCTestExpectation(description: "Authentication performs a callback")

        client.authenticate(username: "invalid.username", password: "whatever") { error in
            expectation.fulfill()
            XCTAssertNotNil(error, "Failed authentication should return an error")
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testValidLoginResultsInTokenReturned() {
        let client = OAuthClient(url: testEnvironment, session: URLSession(configuration: .ephemeral))
        let expectation = XCTestExpectation(description: "Authentication performs a callback")

        client.authenticate(username: TestCredentials.username, password: TestCredentials.password) { error in
            expectation.fulfill()
            XCTAssertNil(error, "Failed authentication should not return an error")
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
