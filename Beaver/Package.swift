// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Beaver",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "Beaver",
            targets: ["Beaver"]),
    ],
    targets: [
        .target(
            name: "Beaver",
            dependencies: []),
        .testTarget(
            name: "BeaverTests",
            dependencies: ["Beaver"]),
    ]
)
