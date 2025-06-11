import Builtin

#if hasFeature(RawLayout) && hasFeature(BuiltinAddressOfRawLayout)

    /// A construct that creates uninitialized instances of type Value.
    ///
    /// This is much similar to Rust's MaybeUninit
    /// This version was gotten from swift forums [here](https://forums.swift.org/t/accepted-with-modifications-se-0453-inlinearray-formerly-vector-a-fixed-size-array/77678/55)
    @_rawLayout(like: Value, movesAsLike)
    @frozen
    @dynamicMemberLookup
    public struct MaybeUninit<Value: ~Copyable>: ~Copyable {

        @_transparent
        @_alwaysEmitIntoClient
        internal var rawPointer: Builtin.RawPointer {
            Builtin.addressOfRawLayout(self)
        }

        /// Creates an uninitialized MaybeUninit<Value> instance.
        /// This is useful for types whose value is not ready yet
        @_transparent
        @_alwaysEmitIntoClient
        public init() {}

        deinit {
            _ = self.pointer.move()
        }

        /// Fully initialize the value of the MaybeUninit<Value> instance.
        /// - Parameter to: the value to use in initializing this instance
        @_transparent
        @_alwaysEmitIntoClient
        public func initialize(to initialValue: consuming Value) {
            assignIntoRaw(consume initialValue, pointer: self.rawPointer)
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
        internal let rawPointer: Builtin.RawPointer

        /// Creates an uninitialized MaybeUninit<Value> instance.
        /// This is useful for types whose value is not ready yet
        @_transparent
        @_alwaysEmitIntoClient
        public init() {
            self.rawPointer = createRawPointer(Value.self)
        }

        deinit {
            _ = deallocRaw(of: Value.self, pointer: self.rawPointer)
        }

        /// Fully initialize the value of the MaybeUninit<Value> instance.
        /// - Parameter to: the value to use in initializing this instance
        @_transparent
        @_alwaysEmitIntoClient
        public func initialize(to initialValue: consuming Value) {
            storeIntoRaw(consume initialValue, pointer: self.rawPointer)
        }
    }

#endif

extension MaybeUninit where Value: ~Copyable {
    @_transparent
    @_alwaysEmitIntoClient
    internal var pointer: UnsafeMutablePointer<Value> {
        UnsafeMutablePointer<Value>(self.rawPointer)
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

extension MaybeUninit where Value: BitwiseCopyable {
    /// Creates a new MaybeUninit<Value> in an uninitialized state, then initialize by
    /// filling up the memory with value of 0s.
    ///
    /// It depends on Value being zero initializable which most BitwiseCopyable types are.
    /// ```swift
    /// struct ExampleStruct {
    ///    let x, y: UInt
    /// }
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

    /// The value this instance contains
    ///
    /// Warning: might cause UB (undefined behaviour) if this instance was not fully initialized
    @_transparent
    @_alwaysEmitIntoClient
    public var value: Value {
        @_transparent
        unsafeAddress {
            UnsafePointer<Value>(self.pointer)
        }
        @_transparent
        unsafeMutableAddress {
            self.pointer
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
