import XCTest
@testable import Partial

struct Foo {
    var str: String
    var bar: Bar
}

struct Bar: PartialConvertible, Equatable {
    var str: String
    var baz: Baz
    
    init(str: String, baz: Baz) {
        self.str = str
        self.baz = baz
    }
    
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

struct Baz: PartialConvertible, Equatable {
    var str: String
    
    init(str: String) {
        self.str = str
    }
    
    init(partial: Partial<Self>) throws {
        self.str = try partial.value(for: \.str)
    }
    
    func partial() -> Partial<Self> {
        var partial = Partial<Self>()
        partial.str = str
        return partial
    }
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
    }
}

