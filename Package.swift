// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SunKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15),
        .tvOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SunKit",
            targets: ["SunKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SunKit",
            dependencies: []
        ),
        .testTarget(
            name: "SunKitTests",
            dependencies: ["SunKit"]
        ),
    ]
)
