public final class SlackSourcingCommandLineTool {
    private let arguments: [String]

    public var hasHelloWorld: Bool { return arguments.contains("hello world") }

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        print("Hello from the core")
    }
}
