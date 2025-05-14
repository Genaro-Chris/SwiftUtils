/// Tuple of values
/// 
/// This provides a nominal interface to the original Swift tuple construct
@dynamicMemberLookup
@frozen
public struct Tuple<each Value> {

    /// the tuple
    @_alwaysEmitIntoClient
    internal var tuple: (repeat each Value)

    /// Initializes the Tuple instance with a variadic arguments list of arbitrary types
    ///
    /// Warning: fails at runtime if the count of arguments passed in is less than two
    /// - Parameter value: a variadic list of values of arbitrary type
    @_alwaysEmitIntoClient
    @_transparent
    public init(by value: repeat each Value) {
        tuple = (repeat each value)
    }

    /// Initializes the Tuple instance with a tuple of values
    ///
    /// Warning: fails at runtime if the count of arguments passed in is less than two
    /// - Parameter value: tuple of values
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

    /// This function is useful in situation where one want to do some destructuring
    /// - Returns: the tuple value
    @_alwaysEmitIntoClient
    @_transparent
    public func tupleValue() -> (repeat each Value) {
        return (repeat each self.tuple)
    }

    /// Check if a certain type is include in this tuple instance
    /// - Parameter type: the metatype to search
    /// - Returns: true if type was found otherwise false
    @_alwaysEmitIntoClient
    @_transparent
    public func checkIfType<T>(of type: T.Type) -> Bool {
        for meta in repeat ((each Value).self) {
            if meta == type {
                return true
            }
        }
        return false
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
        guard lhs.count == rhs.count else {
            return false
        }
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
    public static func ~= (pattern: (repeat each Value), value: Self) -> Bool {
        return Tuple(with: (repeat each pattern)) == value
    }

    @_alwaysEmitIntoClient
    @_transparent
    public static func ~= (pattern: Self, value: (repeat each Value)) -> Bool {
        return pattern == Tuple(with: (repeat each value))
    }
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
