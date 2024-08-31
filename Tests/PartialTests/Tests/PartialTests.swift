import XCTest
@testable import Partial
@testable import PartialMacro
import SwiftSyntaxMacroExpansion
import SwiftSyntax

@PartialConvertible
struct Foo: Equatable {
    var str: String
    var bar: Bar
    var opt: Bool?
    var optBar: Bar?
}

struct Bar: Equatable {
    var str: String
    var baz: Baz
}

extension Bar: PartialConvertible {
    init(partial: Partial<Self>) throws {
        self.str = try partial.value(for: \.str)
        self.baz = try partial.value(for: \.baz)
    }
    
    func partial() -> Partial<Self> {
        var partial = Partial<Self>()
        partial.str = str
        partial.baz = baz
        return partial
    }
}

@PartialConvertible
struct Baz: Equatable {
    var str: String
}

final class PartialTests: XCTestCase {

    func testPartial() {
        var partial = Partial<Foo>()
        XCTAssertNil(partial.str)
        XCTAssertNil(partial.bar)
        XCTAssertNil(partial.bar.str)
        XCTAssertNil(partial.bar.baz)
        XCTAssertNil(partial.bar.baz.str)
        // Set any value through dynamicMember
        partial.str = "hi"
        XCTAssertEqual(partial.str, "hi")
        // Set PartialConvertible through unwrapped dynamicMember
        partial.bar = Bar(str: "hello", baz: Baz(str: "world"))
        XCTAssertEqual(partial.bar.str, "hello")
        XCTAssertEqual(partial.bar.baz, Baz(str: "world"))
        XCTAssertEqual(partial.bar.baz.str, "world")
        XCTAssertEqual(partial.bar, Bar(str: "hello", baz: Baz(str: "world")))
        // Unset PartialConvertible through unwrapped dynamicMember
        partial.bar = nil
        XCTAssertNil(partial.bar)
        XCTAssertNil(partial.bar.str)
        XCTAssertNil(partial.bar.baz)
        XCTAssertNil(partial.bar.baz.str)
        // Set PartialConvertible through wrapped dynamicMember
        partial.bar.str = "hello"
        XCTAssertNil(partial.bar)
        partial.bar.baz = Baz(str: "world")
        XCTAssertEqual(partial.bar.str, "hello")
        XCTAssertEqual(partial.bar.baz, Baz(str: "world"))
        XCTAssertEqual(partial.bar.baz.str, "world")
        XCTAssertEqual(partial.bar, Bar(str: "hello", baz: Baz(str: "world")))
        // Unset PartialConvertible through unwrapped dynamicMember when it was set through wrapped dynamicMember
        partial.bar = nil
        XCTAssertNil(partial.bar)
        XCTAssertNil(partial.bar.str)
        XCTAssertNil(partial.bar.baz)
        XCTAssertNil(partial.bar.baz.str)
        
        partial.bar = Bar(str: "hello", baz: Baz(str: "world"))
        XCTAssertEqual(partial.bar.str, "hello")
        XCTAssertEqual(partial.bar.baz, Baz(str: "world"))
        XCTAssertEqual(partial.bar, Bar(str: "hello", baz: Baz(str: "world")))
        // Unset PartialConvertible through wrapped dynamicMember when it was set through unwrapped dynamicMember
        partial.bar.str = nil
        XCTAssertNil(partial.bar)
        XCTAssertNil(partial.bar.str)
        
        // Partial value stays
        XCTAssertEqual(partial.bar.baz, Baz(str: "world"))
        XCTAssertEqual(partial.bar.baz.str, "world")
        
        // Optionals
        partial.opt = nil
        XCTAssertNil(partial.opt)
        partial.opt = true
        XCTAssertEqual(partial.opt, true)
        partial.opt = nil
        XCTAssertNil(partial.opt)
        partial.optBar = nil
        partial.optBar.str = "hello"
        XCTAssertEqual(partial.optBar.str, "hello")
        partial.optBar.baz.str = "world"
        XCTAssertEqual(partial.optBar.baz.str, "world")
        XCTAssertEqual(partial.optBar, Bar(str: "hello", baz: Baz(str: "world")))
        // If all required values are set, complete should succeed
        partial.bar.str = "hello"
        XCTAssertEqual(try partial.complete(), Foo(str: "hi", bar: Bar(str: "hello", baz: Baz(str: "world")), opt: nil, optBar: Bar(str: "hello", baz: Baz(str: "world"))))
        // If any optional value is unset, complete should still succeed
        partial.optBar.baz.str = nil
        XCTAssertEqual(try partial.complete(), Foo(str: "hi", bar: Bar(str: "hello", baz: Baz(str: "world")), opt: nil, optBar: nil))
    }
    
    func testMacro() {
        let source: SourceFileSyntax =
            """
            @PartialConvertible
            struct Foo {
                var str: String
                var bar: Bar
            }
            """
        
        let file = BasicMacroExpansionContext.KnownSourceFile(
            moduleName: "MyModule",
            fullFilePath: "test.swift"
        )
        
        let context = BasicMacroExpansionContext(sourceFiles: [source: file])
        
        let transformedSF = source.expand(
            macros:["PartialConvertible": PartialConvertibleMacro.self],
            in: context
        )
        
        let expectedDescription =
            """
            
            struct Foo {
                var str: String
                var bar: Bar
            }
            
            extension Foo: PartialConvertible {
                init(partial: Partial<Self>) throws {
                    self.str = try partial.value(for: \\.str)
                    self.bar = try partial.value(for: \\.bar)
                }
                func partial() -> Partial<Self> {
                    var partial = Partial<Self>()
                    partial.str = str
                    partial.bar = bar
                    return partial
                }
            }
            """
        
        XCTAssertEqual(transformedSF.description, expectedDescription)
    }
}
