// swift-tools-version: 6.0
import PackageDescription

let strictSwiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]

let package = Package(
    name: "IOSSubstrate",
    platforms: [
        .iOS(.v18),
        .macOS("26.0"),
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
            swiftSettings: strictSwiftSettings,
        ),
        .testTarget(
            name: "IOSSubstrateTests",
            dependencies: ["IOSSubstrate"],
            swiftSettings: strictSwiftSettings,
        ),
    ],
)
