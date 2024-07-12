import Partial

struct StringWrapper: PartialConvertible, Hashable, ExpressibleByStringLiteral {
    func partial() -> Partial<Self> {
        var partial = Partial<Self>()
        partial.string = string
        return partial
    }
    
    
    let string: String
    
    init(stringLiteral value: String) {
        self.string = value
    }
    
    init(partial: Partial<Self>) throws {
        string = try partial.value(for: \.string)
    }
}
