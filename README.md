# Partial

[![Build Status](https://github.com/JosephDuffy/Partial/workflows/Tests/badge.svg)](https://github.com/JosephDuffy/Partial/actions?query=workflow%3ATests)
![Compatible with macOS, iOS, watchOS, tvOS, and Linux](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-4BC51D.svg)
![Compatible with Swift 5.2+](https://img.shields.io/badge/swift-5.2%2B-4BC51D.svg)
![Supported Xcode Versions](https://img.shields.io/badge/Xcode-12.5.1%20%7C%2013.2.1-success)<!---xcode-version-badge-markdown-->
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org/pods/Partial)
[![MIT License](https://img.shields.io/badge/License-MIT-4BC51D.svg?style=flat)](./LICENSE)

Partial is a type-safe wrapper that mirrors the properties of the wrapped type but makes each property optional.

```swift
@PartialConvertible
struct Size {
    let width: Int
    let height: Int
}

var partialSize = Partial<Size>()

partialSize.width = 6016
partialSize.height = 3384
try partialSize.complete() // `Size(width: 6016, height: 3384)`

partialSize.height = nil
try partialSize.complete() // Throws `Partial<Size>.Error<Int>.keyPathNotSet(\.height)`
```

## Usage overview

Partial has a `KeyPath`-based API, allowing it to be fully type-safe. Setting, retrieving, and removing key paths is possible via dynamic member lookup or functions.

```swift
var partialSize = Partial<Size>()
// Set value
partialSize.width = 6016
// Retrieve value
partialSize.width // `Optional<CGFloat>(6016)`
try partialSize.value(for: \.height) // `3384`
// Remove value
partialSize.width = nil
```

## Adding support to your own types

Adopting the `PartialConvertible` protocol declares that a type can be initialised with a partial:

```swift
protocol PartialConvertible {
    init(partial: Partial<Self>) throws
    func partial() -> Partial<Self>
}
```

The `@PartialConvertible` macro can be used for adding conformance to your own type.

To add `PartialConvertible` conformance to an imported type like `CGSize` you can use `value(for:)` which will throw if a non-optional value was nil, to retrieve the `width` and `height` values:

```swift
extension CGSize: PartialConvertible {
    public init(partial: Partial<Self>) throws {
        self.init(
            width: try partial.value(for: \.width),
            height: try partial.value(for: \.height)
        )
    }
    
    public func partial() -> Partial<Self> {
        var partial = Partial<Self>()
        partial.width = width
        partial.height = height
        return partial
    }
}
```

As a convenience it's then possible to complete partials of a type that conforms to `PartialConvertible`:

```swift
let partialSize = Partial<CGSize>()
// ...
let size = try partialSize.complete()
```

`PartialConvertible` conforming types also automatically convert to Partial when accesed through another Partial:

```swift
@PartialConvertible
struct Foo {
    let size: CGSize
} 

var partial = Partial<Foo>()
partial.size.width = 3 // Possible because CGSize is PartialConvertible
partial.size.height = 5
try partial.complete() // `Foo(size: CGSize(width: 3, height: 5))`

partial.size.height = nil
try partial.complete() // Throws `Partial<CGSize>.Error<CGFloat>.keyPathNotSet(\.height)`
```

# Tests and CI

Partial has a full test suite, which is run on [GitHub Actions](https://github.com/JosephDuffy/Partial/actions?query=workflow%3ATests) as part of pull requests. All tests must pass for a pull request to be merged.

Code coverage is collected and reported to to [Codecov](https://codecov.io/gh/JosephDuffy/Partial). 100% coverage is not possible; some lines of code should never be hit but are required for type-safety, and Swift does not track `deinit` functions as part of coverage. These limitations will be considered when reviewing a pull request that lowers the overall code coverage.

# Installation

## SwiftPM

To install via [SwiftPM](https://github.com/apple/swift-package-manager) add the package to the dependencies section and as the dependency of a target:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/JosephDuffy/Partial.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "MyApp", dependencies: ["Partial"]),
    ],
    ...
)
```

## Carthage

To install via [Carthage](https://github.com/Carthage/Carthage) add to following to your `Cartfile`:

```
github "JosephDuffy/Partial"
```

Run `carthage update Partial` to build the framework and then drag the built framework file in to your Xcode project. Partial provides pre-compiled binaries, [which can cause some issues with symbols](https://github.com/Carthage/Carthage#dwarfs-symbol-problem). Use the `--no-use-binaries` flag if this is an issue.

Remember to [add Partial to your Carthage build phase](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos):

```
$(SRCROOT)/Carthage/Build/iOS/Partial.framework
```

and

```
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/Partial.framework
```

## CocoaPods

To install via [CocoaPods](https://cocoapods.org) add the following to your Podfile:

```ruby
pod 'Partial'
```

and then run `pod install`.

# License

The project is released under the MIT license. View the [LICENSE](./LICENSE) file for the full license.
