// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Surfr",
    products: [
        .library(
            name: "Surfr",
            targets: ["Surfr"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/DariuszGulbicki/Logging-Camp.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/johnsundell/ink.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Surfr",
            dependencies: [
                .product(name: "Swifter", package: "swifter"),
                .product(name: "LoggingCamp", package: "Logging-Camp"),
                .product(name: "Ink", package: "ink"),
            ]),
        .testTarget(
            name: "SurfrTests",
            dependencies: ["Surfr"]),
    ]
)
