// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "webim-client-sdk-ios",
    platforms: [
            .iOS(.v8)
        ],
    products: [
        .library(
            name: "WebimClientLibrary",
            targets: ["WebimClientLibrary"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.2")
    ],
    targets: [
        .target(
            name: "WebimClientLibrary",
            dependencies: [
            .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "WebimClientLibrary")
    ]
)
