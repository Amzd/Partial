import Quick
import Nimble

@testable
import Partial

final class PartialTests: QuickSpec {
    
    override func spec() {
        
        struct A {
            var a: String
            struct Foo: PartialConvertible {
                init(a: String) {
                    self.a = a
                }
                init(partial: Partial<Self>) throws {
                    self.a = try partial.value(for: \.a)
                }
                
                func partial() -> Partial<Self> {
                    var partial = Partial<Self>()
                    partial.a = a
                    return partial
                }
                
                var a: String
            }
            var b: Foo
        }
        var pa = Partial<A>()
        //                    let a = pa.b
        //                    pa.b = ""
        
    }
    
}

