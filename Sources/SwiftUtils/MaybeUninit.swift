import Builtin

#if hasAttribute(RawLayout) || hasFeature(RawLayout) && hasFeature(BuiltinAddressOfRawLayout) || hasAttribute(BuiltinAddressOfRawLayout)

    /// A wrapper type to construct uninitialized instances of Value type.
    ///
    /// This is much similar to Rust's MaybeUnint
    @_rawLayout(like: Value, movesAsLike)
    @frozen
    @dynamicMemberLookup
    public struct MaybeUninit<Value: ~Copyable>: ~Copyable {

        @_transparent
        @_alwaysEmitIntoClient
        internal var _address: UnsafeMutablePointer<Value> {
            UnsafeMutablePointer<Value>(self._rawAddress)
        }

        @_transparent
        @_alwaysEmitIntoClient
        internal var _rawAddress: Builtin.RawPointer {
            Builtin.addressOfRawLayout(self)
        }

        @_transparent
        @_alwaysEmitIntoClient
        /// Initializes the value of the `MaybeUninit<Value>` instance.
        /// - Returns:
        public func initialize(to initialValue: consuming Value) {
            self._address.initialize(to: initialValue)
        }

        /// Creates a new MaybeUninit<Value> in an uninitialized state.
        @_transparent
        @_alwaysEmitIntoClient
        public init() {}

        deinit {
            _ = self._address.move()
        }

        ///
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public consuming func take() -> Value {
            let value = self._address.move()
            discard self
            return value
        }

        ///
        @_transparent
        @_alwaysEmitIntoClient
        public var value: Value {
            @_transparent
            unsafeAddress {
                return UnsafePointer<Value>(self._address)
            }
            @_transparent
            mutating unsafeMutableAddress {
                return self._address
            }
        }

        /// Initialize the MaybeUninit's instance through an UnsafeMutablePointer
        /// - Parameter body: the closure that initializes the value
        /// - Returns: anything the body parameter returns
        @_alwaysEmitIntoClient
        @_transparent
        public func unsafeInitialize<T>(_ body: (UnsafeMutablePointer<Value>) throws -> T)
            rethrows
            -> T
        {
            try body(self._address)
        }
    }

    extension MaybeUninit where Value: BitwiseCopyable {
        /// Creates a new MaybeUninit<Value> in an uninitialized state, then fills the memory with value  of 0.
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
            let result = Self()
            result.unsafeInitialize { ptr in
                UnsafeMutableRawPointer(ptr).storeBytes(of: 0, as: UInt8.self)
            }
            return result
        }
    }

    extension MaybeUninit {
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

#else

    /// A wrapper type to construct uninitialized instances of Value type.
    ///
    /// This is much similar to Rust's MaybeUninit
    @frozen
    @dynamicMemberLookup
    public struct MaybeUninit<Value: ~Copyable>: ~Copyable {

        @_alwaysEmitIntoClient
        internal let _rawAddress: Builtin.RawPointer

        @_transparent
        @_alwaysEmitIntoClient
        internal var _address: UnsafeMutablePointer<Value> {
            UnsafeMutablePointer<Value>(self._rawAddress)
        }

        /// Initializes the value of the `MaybeUninit<Value>` instance.
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public func initialize(to initialValue: consuming Value) {
            Builtin.bindMemory(self._rawAddress, (1)._builtinWordValue, Value.self)
            Builtin.initialize(initialValue, self._rawAddress)
        }

        /// Creates a new MaybeUninit<Value> in an uninitialized state.
        /// This is useful for type
        @_transparent
        @_alwaysEmitIntoClient
        public init() {
            self._rawAddress = Builtin.allocRaw(
                findByteCount(of: Value.self)._builtinWordValue,
                findAlignment(of: Value.self)._builtinWordValue)
            Builtin.bindMemory(self._rawAddress, (1)._builtinWordValue, Value.self)
        }

        deinit {
            _ = self._address.deinitialize(count: 1)
            Builtin.deallocRaw(self._rawAddress, (-1)._builtinWordValue, (0)._builtinWordValue)
        }

        ///
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public consuming func take() -> Value {
            let value = _address.move()
            Builtin.deallocRaw(self._rawAddress, (-1)._builtinWordValue, (0)._builtinWordValue)
            discard self
            return value
        }

        ///
        @_transparent
        @_alwaysEmitIntoClient
        public var value: Value {
            @_transparent
            _read {
                yield self._address.pointee
            }
            @_transparent
            _modify {
                yield &self._address.pointee
            }
        }

        /// Initialize the MaybeUninit's instance through an UnsafeMutablePointer
        /// - Parameter body: the closure that initializes the value
        /// - Returns: anything the body parameter returns
        @_alwaysEmitIntoClient
        @_transparent
        public func unsafeInitialize<T>(_ body: (UnsafeMutablePointer<Value>) throws -> T)
            rethrows
            -> T
        {
            try body(self._address)
        }

    }

    extension MaybeUninit where Value: BitwiseCopyable {
        /// Creates a new MaybeUninit<Value> in an uninitialized state, then fills the memory with value  of 0.
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
            let result = Self()
            result.unsafeInitialize { ptr in
                UnsafeMutableRawPointer(ptr).storeBytes(of: 0, as: UInt8.self)
            }
            return result
        }
    }

    extension MaybeUninit {
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

#endif
