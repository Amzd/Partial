import Partial

struct StringWrapperWrapper: PartialConvertible, Hashable {

    let stringWrapper: StringWrapper
    let optionalStringWrapper: StringWrapper?

    init(stringWrapper: StringWrapper, optionalStringWrapper: StringWrapper?) {
        self.stringWrapper = stringWrapper
        self.optionalStringWrapper = optionalStringWrapper
    }

    init(partial: Partial<Self>) throws {
        stringWrapper = try partial.value(for: \.stringWrapper)
        optionalStringWrapper = try partial.value(for: \.optionalStringWrapper)
    }

    func partial() -> Partial<Self> {
        var partial = Partial<Self>()
        partial.stringWrapper = stringWrapper
        partial.optionalStringWrapper = optionalStringWrapper
        return partial
    }
}
