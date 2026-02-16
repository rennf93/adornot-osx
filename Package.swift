// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AdBlockReport",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    targets: [
        .executableTarget(
            name: "AdBlockReport",
            path: "Sources/AdBlockReport"
        ),
        .testTarget(
            name: "AdBlockReportTests",
            dependencies: ["AdBlockReport"],
            path: "Tests/AdBlockReportTests"
        ),
    ],
    swiftLanguageModes: [.v5]
)
