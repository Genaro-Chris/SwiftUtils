import Builtin

#if hasFeature(RawLayout) && hasFeature(BuiltinAddressOfRawLayout)

    /// A construct that creates uninitialized instances of type Value.
    ///
    /// This is much similar to Rust's MaybeUninit
    @_rawLayout(like: Value, movesAsLike)
    @frozen
    @dynamicMemberLookup
    public struct MaybeUninit<Value: ~Copyable>: ~Copyable {

        @_transparent
        @_alwaysEmitIntoClient
        internal var rawPointer: Builtin.RawPointer {
            Builtin.addressOfRawLayout(self)
        }

        /// Fully initialize the value of the MaybeUninit<Value> instance.
        /// - Parameter to: the value to use in initializing this instance
        @_transparent
        @_alwaysEmitIntoClient
        public func initialize(to initialValue: consuming Value) {
            self.pointer.initialize(to: initialValue)
        }

        /// Creates an uninitialized MaybeUninit<Value> instance.
        /// This is useful for types whose value is not ready yet
        @_transparent
        @_alwaysEmitIntoClient
        public init() {}

        deinit {
            _ = self.pointer.move()
        }

        /// Consume the MaybeUninit<Value> instance and return any value the instance had
        ///
        /// Warning: might cause UB (undefined behaviour) if the instance was not fully initialized
        /// - Returns: the value this instance had if it had a fully initialized value otherwise garbage value
        @_transparent
        @_alwaysEmitIntoClient
        public consuming func take() -> Value {
            let value: Value = self.pointer.move()
            discard self
            return value
        }
    }

#else

    /// A construct that creates uninitialized instances of Value type.
    ///
    /// This is much similar to Rust's MaybeUninit
    @frozen
    @dynamicMemberLookup
    public struct MaybeUninit<Value: ~Copyable>: ~Copyable {

        @_alwaysEmitIntoClient
        internal let rawPointer: Builtin.RawPointer = createRawPointer(Value.self)

        /// Fully initialize the value of the MaybeUninit<Value> instance.
        /// - Parameter to: the value to use in initializing this instance
        @_transparent
        @_alwaysEmitIntoClient
        public func initialize(to initialValue: consuming Value) {
            assignIntoRaw(consume initialValue, pointer: self.rawPointer)
        }

        /// Creates an uninitialized MaybeUninit<Value> instance.
        /// This is useful for types whose value is not ready yet
        @_transparent
        @_alwaysEmitIntoClient
        public init() {}

        deinit {
            _ = deallocRaw(of: Value.self, pointer: self.rawPointer)
        }

        /// Consume the MaybeUninit<Value> instance and return any value the instance had
        ///
        /// Warning: might cause UB (undefined behaviour) if the instance was not fully initialized
        /// - Returns: the value this instance had if it had a fully initialized value otherwise garbage value
        @_transparent
        @_alwaysEmitIntoClient
        public consuming func take() -> Value {
            let value: Value = deallocRaw(of: Value.self, pointer: self.rawPointer)
            discard self
            return value
        }
    }

#endif

extension MaybeUninit where Value: BitwiseCopyable {
    /// Creates a new MaybeUninit<Value> in an uninitialized state, then initialize by
    ///  filling up the memory with value of 0s.
    ///
    /// It depends on Value being zero initilizable which most BitwiseCopyable types are.
    /// ```swift
    ///     struct ExampleStruct {
    ///         let x, y: UInt
    ///     }
    /// ```
    /// For example, MaybeUninit<ExampleStruct>.zeroInitialize() is fully initialized,
    /// but MaybeUninit<any ~BitwiseCopyable>.zeroInitialize() is not because it might be or contains a reference.
    @_alwaysEmitIntoClient
    @_transparent
    public static func zeroInitialize() -> Self {
        let result: MaybeUninit<Value> = Self()
        result.unsafeInitialize { pointer in
            let count: Int = MemoryLayout<Value>.stride
            pointer.withMemoryRebound(to: UInt8.self, capacity: count) { pointer in
                pointer.initialize(repeating: 0, count: count)
            }
        }
        return result
    }
}

extension MaybeUninit where Value: ~Copyable {
    @_transparent
    @_alwaysEmitIntoClient
    internal var pointer: UnsafeMutablePointer<Value> {
        UnsafeMutablePointer<Value>(self.rawPointer)
    }
}

extension MaybeUninit where Value: ~Copyable {

    /// The value this instance contains
    ///
    /// Warning: might cause UB (undefined behaviour) if this instance was not fully initialized
    @_transparent
    @_alwaysEmitIntoClient
    public var value: Value {
        @_transparent
        _read {
            yield self.pointer.pointee
        }
        @_transparent
        _modify {
            yield &self.pointer.pointee
        }
    }
}

extension MaybeUninit where Value: ~Copyable {

    /// Fully initialize the MaybeUninit's instance through an UnsafeMutablePointer
    /// - Parameter body: the closure that initializes the value
    /// - Returns: anything the body parameter returns
    /// - Throws: if the closure throws any error
    @_alwaysEmitIntoClient
    @_transparent
    public func unsafeInitialize<T>(_ body: (UnsafeMutablePointer<Value>) throws -> T)
        rethrows
        -> T
    {
        try body(self.pointer)
    }
}

extension MaybeUninit where Value: ~Copyable {
    @_alwaysEmitIntoClient
    public subscript<T>(dynamicMember member: WritableKeyPath<Value, T>) -> T {
        @_transparent
        _read {
            yield self.value[keyPath: member]
        }
        @_transparent
        _modify {
            yield &self.value[keyPath: member]
        }
    }

    @_alwaysEmitIntoClient
    public subscript<T>(dynamicMember member: KeyPath<Value, T>) -> T {
        @_transparent
        _read {
            yield self.value[keyPath: member]
        }
    }
}
