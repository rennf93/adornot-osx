// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "AdBlockReport",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    targets: [
        .executableTarget(
            name: "AdBlockReport",
            path: "Sources/AdBlockReport",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "AdBlockReportTests",
            dependencies: ["AdBlockReport"],
            path: "Tests/AdBlockReportTests"
        ),
    ],
    swiftLanguageModes: [.v5]
)
