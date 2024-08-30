/// A type that can be initialised with a `Partial` value that wraps itself
public protocol PartialConvertible {
    
    /// Create a new instance of this type, retrieving values from the partial.
    ///
    /// `Partial` provides convenience functions that throw relevant errors:
    ///
    /// ```
    /// foo = try partial.value(for: \.foo)
    /// ```
    ///
    /// - Parameter partial: The partial to retrieve values from
    init(partial: Partial<Self>) throws
    
    func partial() -> Partial<Self>
    
}

#if swift(>=5.9)
@attached(extension, conformances: PartialConvertible, names: named(init(partial:)), named(partial()))
public macro PartialConvertible() = #externalMacro(module: "PartialMacro", type: "PartialConvertibleMacro")
#endif
