// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlackSourcing",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "3.0.2"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "1.5.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SlackSourcing",
            dependencies: ["SlackSourcingCore", "OAuth"]),
        .target(
            name: "SlackSourcingCore",
            dependencies: ["Starscream", "Alamofire"]),
        .target(
            name: "OAuth",
            dependencies: ["SwiftSoup"]),
        .testTarget(
            name: "SlackSourcingTests",
            dependencies: ["SlackSourcingCore"]),
        .testTarget(
            name: "OAuthTests",
            dependencies: ["OAuth"])
    ]
)
