import Builtin

/// Tuple of values
@dynamicMemberLookup
@frozen
public struct Tuple<each Value> {

    /// the tuple
    @_alwaysEmitIntoClient
    internal var tuple: (repeat each Value)

    /// Initializes the Tuple instance with a varidiac list of values
    /// 
    /// Warning: fails at runtime if the count of arguments passed in is less than two
    /// - Parameter value: a varidiac list of values
    @_alwaysEmitIntoClient
    @_transparent
    public init(by value: repeat each Value) {
        precondition(
            getTupleCount(repeat (each Value).self) > 1,
            "Cannot instantiate a tuple type with a single value, or an empty tuple")
        tuple = (repeat each value)
    }

    /// Initializes the Tuple instance with a tuple of values
    /// 
    /// Warning: fails at runtime if the count of arguments passed in is less than two
    /// - Parameter value: tuple of values
    @_alwaysEmitIntoClient
    @_transparent
    public init(with value: (repeat each Value)) {
        precondition(
            getTupleCount(repeat (each Value).self) > 1,
            "Cannot instantiate a tuple type with a single value, or an empty tuple")
        tuple = value
    }

    /// The number of values this Tuple instance has
    @_alwaysEmitIntoClient
    @_transparent
    public var count: Int {
        getTupleCount(repeat (each Value).self)
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
