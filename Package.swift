// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IOSSubstrate",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "IOSSubstrate",
            targets: ["IOSSubstrate"],
        ),
    ],
    targets: [
        .target(
            name: "IOSSubstrate",
        ),
        .testTarget(
            name: "IOSSubstrateTests",
            dependencies: ["IOSSubstrate"],
        ),
    ],
)
