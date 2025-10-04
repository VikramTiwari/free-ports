// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PortManager",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PortManager", targets: ["PortManager"])
    ],
    targets: [
        .executableTarget(
            name: "PortManager",
            dependencies: [],
            path: "Sources/PortManager"
        )
    ]
)
