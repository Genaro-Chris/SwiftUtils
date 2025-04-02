import Builtin

@dynamicMemberLookup
@frozen
public struct Tuple<each Value> {

    /// the tuple
    @_alwaysEmitIntoClient
    public var tuple: (repeat each Value)

    /// Initializes the Tuple instance with a varidiac list of values
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
    subscript<T>(dynamicMember member: some ExpressibleByStringLiteral) -> T {
        @_transparent
        _read {
            guard let index = Int(String(describing: member)) else {
                preconditionFailure("Argument must be a integral literal")
            }

            guard (0..<self.count).contains(index) else {
                preconditionFailure("Index out of bounds")
            }

            var tupleIndex = 0

            for meta in repeat (each self.tuple) {
                if tupleIndex == index && type(of: meta) == T.self {
                    yield(meta as! T)
                    return
                }
                tupleIndex += 1
            }

            preconditionFailure(
                "The supplied result type isn't of the same type as the one at the supplied index"
            )
        }

    }
}

extension Tuple: Equatable where repeat each Value: Equatable {
    @_alwaysEmitIntoClient
    @_transparent
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else {
            preconditionFailure("Cannot compare two tuple instance of different counts")
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
