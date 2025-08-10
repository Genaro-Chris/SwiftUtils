/// Tuple of values
///
/// This provides a nominal interface to the original Swift tuple construct while providing some
/// compabilities with swift tuples
///
/// ```swift
/// var tuple = Tuple(by: 1, 0.4, Float(73), "Hello", SomeError.unknown)
/// tuple.0 = 100
///
/// // After some time
/// tuple = Tuple(with: (1, 0.4, Float(73), "Hello", SomeError.unknown))
///
/// ```
///
/// This provides a way for extending swift tuple instance for instance addition for methods, conforming to protocols
import Builtin
@dynamicMemberLookup
@frozen
public struct Tuple<each Value> {

    /// the tuple
    @_alwaysEmitIntoClient
    internal var tuple: (repeat each Value)

    /// Initializes the Tuple instance with a variadic arguments list of arbitrary types
    ///
    /// - Parameter by: a variadic list of values of arbitrary type
    @_alwaysEmitIntoClient
    @_transparent
    public init(by value: repeat each Value) {
        tuple = (repeat each value)
    }

    /// Initializes the Tuple instance with a tuple of values
    ///
    /// - Parameter with: tuple of arbitrary values
    @_alwaysEmitIntoClient
    @_transparent
    public init(with value: (repeat each Value)) {
        tuple = value
    }

    /// The number of values this Tuple instance has
    @_alwaysEmitIntoClient
    @_transparent
    public var count: Int {
        getTupleCount(repeat (each Value).self)
    }

    /// Returns as a normal swift tuple
    /// - Returns: the tuple value
    ///
    /// This function is useful in situation where one want to do some destructuring
    @_alwaysEmitIntoClient
    @_transparent
    public func tupleValue() -> (repeat each Value) {
        return (repeat each self.tuple)
    }

    /// Check if a certain type is included in this tuple instance
    /// - Parameter type: the metatype to search for
    /// - Returns: true if type was found otherwise false
    ///
    /// ```swift
    /// let tuple = Tuple(by: 1, 0.4, Float(73), "Hello", SomeError.unknown)
    ///
    /// if tuple.checkForType(Float.self) {
    ///     // tuple contains a float value in it
    /// }
    ///
    /// ```
    @_alwaysEmitIntoClient
    @_transparent
    public func checkForType<T>(_ type: T.Type) -> Bool {
        return iterateOverMetatypes(of: (repeat (each Value).self), expected: type)
    }
}

extension Tuple {
    @_alwaysEmitIntoClient
    public subscript<T>(dynamicMember member: WritableKeyPath<(repeat each Value), T>) -> T {
        @_transparent
        _read {
            yield self.tuple[keyPath: member]
        }

        @_transparent
        _modify {
            yield &self.tuple[keyPath: member]
        }
    }

    @_alwaysEmitIntoClient
    public subscript<T>(dynamicMember member: KeyPath<(repeat each Value), T>) -> T {
        @_transparent
        _read {
            yield self.tuple[keyPath: member]
        }
    }
}

extension Tuple: Equatable where repeat each Value: Equatable {
    @_alwaysEmitIntoClient
    @_transparent
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for (lhsValue, rhsValue) in repeat (each lhs.tuple, each rhs.tuple) {
            if lhsValue != rhsValue {
                return false
            }
        }
        return true
    }
}

extension Tuple where Tuple: Equatable {

    @_alwaysEmitIntoClient
    @_transparent
    public static func ~= (pattern: Self, value: (repeat each Value)) -> Bool {
        return pattern == Tuple(with: (repeat each value))
    }
}

public func ~= <each Value: Equatable>(
    pattern: (repeat each Value), value: Tuple<repeat each Value>
) -> Bool {
    return Tuple(with: (repeat each pattern)) == value
}

public func == <each Value: Equatable>(
    pattern: (repeat each Value), value: Tuple<repeat each Value>
) -> Bool {
    return Tuple(with: (repeat each pattern)) == value
}

public func == <each Value: Equatable>(
    pattern: Tuple<repeat each Value>, value: (repeat each Value)
) -> Bool {
    return pattern == Tuple(with: (repeat each value))
}

public func != <each Value: Equatable>(
    pattern: (repeat each Value), value: Tuple<repeat each Value>
) -> Bool {
    return Tuple(with: (repeat each pattern)) != value
}

public func != <each Value: Equatable>(
    pattern: Tuple<repeat each Value>, value: (repeat each Value)
) -> Bool {
    return pattern != Tuple(with: (repeat each value))
}
