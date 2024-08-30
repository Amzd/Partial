// swift-tools-version:5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Partial",
    platforms: [
        .macOS(.v10_15), .iOS(.v12), .tvOS(.v12), .watchOS(.v4),
    ],
    products: [
        .library(name: "Partial", targets: ["Partial"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax", from: "510.0.0"),
        .package(url: "https://github.com/stackotter/swift-macro-toolkit", from: "0.5.0"),
    ],
    targets: [
        .target(name: "Partial", dependencies: [
            "PartialMacro",
        ]),
        .testTarget(name: "PartialTests", dependencies: [
            "Partial",
            "PartialMacro",
        ]),
        .macro(name: "PartialMacro", dependencies:[
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
        ]),
    ],
    swiftLanguageVersions: [.v5]
)
