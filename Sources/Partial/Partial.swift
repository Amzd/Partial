import Foundation

/// A struct that mirrors the properties of `Wrapped`, making each of the
/// types optional.
@dynamicMemberLookup
public struct Partial<Wrapped> {
    /// The values that have been set.
    private var values: [PartialKeyPath<Wrapped>: Any] = [:] {
        willSet {
            assert(newValue.keys.allSatisfy { keyPath in
                String(describing: keyPath).contains(".", amount: 1)
            }, "This should not be possible but a value with multiple KeyPath steps was set")
        }
    }

    /// Create an empty `Partial`.
    public init() {}


    /// Retrieve or set a `Partial<Value>` for a given path if the value you are requesting is PartialConvertible.
    ///
    /// - Parameter keyPath: A key path from `Wrapped` to a property of type `Value`.
    /// - Returns: The stored value, or `nil` if a value has not been set.
    public subscript<Value: PartialConvertible>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> Partial<Value> {
        get { getPartial(for: keyPath) }
        set { values[keyPath] = newValue }
    }
    /// Helper function that returns a `Partial<PartialConvertible>` for an `Optional<PartialConvertible>`
    public subscript<Value: PartialConvertible>(dynamicMember keyPath: KeyPath<Wrapped, Optional<Value>>) -> Partial<Value> {
        get { getPartial(for: keyPath) }
        set { values[keyPath] = newValue }
    }
    private func getPartial<V: PartialConvertible>(for keyPath: PartialKeyPath<Wrapped>) -> Partial<V> {
        let value = values[keyPath]
        return value as? Partial<V> ?? (value as? V)?.partial() ?? .init()
    }


    /// Retrieve or set a `PartialConvertible` value for a given path. Will save as `Partial<Value>` and unwrap it to a `Value` when returning.
    ///
    /// - Parameter keyPath: A key path from `Wrapped` to a property of type `Value`.
    /// - Returns: The stored value, or `nil` if a value has not been set.
    public subscript<Value: PartialConvertible>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> Value? {
        get { getPartialConvertible(for: keyPath) }
        set { values[keyPath] = newValue?.partial() }
    }
    /// Helper function that returns `Optional<Value>` instead of `Optional<Optional<Value>>` while storing PartialConvertible types as Partial.
    public subscript<Value: PartialConvertible>(dynamicMember keyPath: KeyPath<Wrapped, Optional<Value>>) -> Value? {
        get { getPartialConvertible(for: keyPath) }
        set { values[keyPath] = newValue?.partial() }
    }
    private func getPartialConvertible<V: PartialConvertible>(for keyPath: PartialKeyPath<Wrapped>) -> V? {
        let value = values[keyPath]
        return try? value as? V ?? (value as? Partial<V>)?.complete()
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
    /// Helper function that returns `Optional<Value>` instead of `Optional<Optional<Value>>`
    @_disfavoredOverload
    public subscript<Value>(dynamicMember keyPath: KeyPath<Wrapped, Optional<Value>>) -> Value? {
        get { values[keyPath] as? Value }
        set { values[keyPath] = newValue }
    }


    /// An error that can be thrown by the `value(for:)` function.
    public enum Error<Value>: Swift.Error {
        /// The key path has not been set.
        case keyPathNotSet(KeyPath<Wrapped, Value>)
    }

    public func value<Value: PartialConvertible>(for keyPath: KeyPath<Wrapped, Value>) throws -> Value {
        assert(String(describing: keyPath).contains(".", amount: 1), "Only use one step deep KeyPaths")
        return try self[dynamicMember: keyPath] ?? { throw Error.keyPathNotSet(keyPath) }()
    }
    public func value<Value: PartialConvertible>(for keyPath: KeyPath<Wrapped, Optional<Value>>) throws -> Value? {
        assert(String(describing: keyPath).contains(".", amount: 1), "Only use one step deep KeyPaths")
        return self[dynamicMember: keyPath]
    }
    public func value<Value>(for keyPath: KeyPath<Wrapped, Value>) throws -> Value {
        assert(String(describing: keyPath).contains(".", amount: 1), "Only use one step deep KeyPaths")
        return try self[dynamicMember: keyPath] ?? { throw Error.keyPathNotSet(keyPath) }()
    }
}

extension Partial where Wrapped: PartialConvertible {
    /// Attempts to initialise a new `Wrapped` with self
    ///
    /// Any errors thrown by `Wrapped.init(partial:)` will be rethrown
    ///
    /// - Returns: The new `Wrapped` instance
    public func complete() throws -> Wrapped {
        return try Wrapped(partial: self)
    }
}

extension Partial: CustomStringConvertible {
    /// A textual representation of the Partial's values.
    public var description: String {
        let valueDescriptions = values.map { key, value in
            let keyDescription = String(describing: key).replacingOccurrences(of: "\\\(Wrapped.self).", with: "")
            return "\(keyDescription): \(value)"
        }
        return "\(type(of: self))(\(valueDescriptions.joined(separator: ", ")))"
    }
}

private extension String {
    /// Helper for assertions. This is not called in any production code.
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
