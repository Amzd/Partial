// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Partial",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "Partial", targets: ["Partial"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", exact: "1.0.0"),
    ],
    targets: [
        .target(name: "Partial"),
        .testTarget(name: "PartialTests", dependencies: [
            "Partial",
        ]),
    ],
    swiftLanguageVersions: [.v5]
)
