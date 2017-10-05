import XCTest
import SlackSourcingCore

class SlackSourcingCommandLineTests: XCTestCase {
    func testPublicInterface() {
        let tool = SlackSourcingCommandLineTool(arguments: ["hello world"])
        XCTAssertTrue(tool.hasHelloWorld)
    }
}
