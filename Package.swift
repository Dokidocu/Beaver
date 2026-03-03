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
    dependencies: [
    ],
    targets: [
        .target(
            name: "Beaver",
            dependencies: [],
            path: "Source"
        ),
        .testTarget(
            name: "BeaverTests",
            dependencies: ["Beaver"],
            path: "BeaverTests"
        ),
    ]
)
