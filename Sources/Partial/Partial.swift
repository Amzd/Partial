import Foundation

/// A struct that mirrors the properties of `Wrapped`, making each of the
/// types optional.
@dynamicMemberLookup
public struct Partial<Wrapped>: CustomStringConvertible {
    
    /// An error that can be thrown by the `value(for:)` function.
    public enum Error<Value>: Swift.Error {
        /// The key path has not been set.
        case keyPathNotSet(KeyPath<Wrapped, Value>)
    }
    
    /// A textual representation of the Partial's values.
    public var description: String {
        return "\(type(of: self))(values: \(String(describing: values)))"
    }
    
    /// The values that have been set.
    private var values: [PartialKeyPath<Wrapped>: Any] = [:] {
        willSet {
            assert(newValue.keys.contains { keyPath in
                String(describing: keyPath).contains(".", amount: 1)
            })
        }
    }
    
    /// Create an empty `Partial`.
    public init() {}
    
    @_disfavoredOverload
    public subscript<Value:PartialConvertible>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> Value? {
        get {
            let value = values[keyPath]
            if let partial = value as? Partial<Value> {
                return try? partial.unwrapped()
            }
            return value as? Value
        }
        set {
            values[keyPath] = newValue?.partial()
        }
    }
    
    public subscript<Value: PartialConvertible>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> Partial<Value> {
        get { values[keyPath] as? Partial<Value> ?? .init() }
        set { values[keyPath] = newValue }
    }
    
    /// Retrieve or set a value for the given key path. Returns `nil` if the value has not been set. If the value is set
    /// to nil it will remove the value.
    ///
    /// - Parameter keyPath: A key path from `Wrapped` to a property of type `Value`.
    /// - Returns: The stored value, or `nil` if a value has not been set.
    @_disfavoredOverload
    public subscript<Value>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> Value? {
        get { values[keyPath] as? Value }
        set { values[keyPath] = newValue }
    }
    
    public func value<Value>(for keyPath: KeyPath<Wrapped, Value>) throws -> Value {
        return try self[dynamicMember: keyPath] ?? { throw Error.keyPathNotSet(keyPath) }()
    }
}

extension Partial where Wrapped: PartialConvertible {
    
    /// Attempts to initialise a new `Wrapped` with self
    ///
    /// Any errors thrown by `Wrapped.init(partial:)` will be rethrown
    ///
    /// - Returns: The new `Wrapped` instance
    public func unwrapped() throws -> Wrapped {
        return try Wrapped(partial: self)
    }
    
}

private extension String {
    func contains(_ element: Element, amount: Int) -> Bool {
        var count = 0
        return allSatisfy { char in
            if char == element {
                count += 1
            }
            return count <= amount
        } && count == amount
    }
}
