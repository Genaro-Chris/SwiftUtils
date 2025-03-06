import Builtin

#if hasAttribute(RawLayout) || hasFeature(RawLayout)

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
            UnsafeMutablePointer<Value>(_rawAddress)
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
            _address.initialize(to: initialValue)
        }

        /// Creates a new MaybeUninit<T> in an uninitialized state.
        @_transparent
        @_alwaysEmitIntoClient
        public init() {}

        deinit {
            _ = _address.move()
        }

        ///
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public consuming func take() -> Value {
            let value = _address.move()
            discard self
            return value
        }

        ///
        @_transparent
        @_alwaysEmitIntoClient
        public var value: Value {
            @_transparent
            unsafeAddress {
                return UnsafePointer<Value>(_address)
            }
            @_transparent
            mutating unsafeMutableAddress {
                return _address
            }
        }

        /// Initialize the MaybeUninit's instance through an UnsafeMutablePointer
        /// - Parameter body: the closure that initializes the value
        /// - Returns: anything the body parameter returns
        public func unsafelyInitialize<T>(_ body: (UnsafeMutablePointer<Value>) throws -> T)
            rethrows
            -> T
        {
            try body(_address)
        }
    }

    extension MaybeUninit where Value: BitwiseCopyable {
        /// Creates a new MaybeUninit<Value> in an uninitialized state, then fills the memory with value of 0.
        ///
        /// It depends on Value being zero initilizable which most BitwiseCopyable types are.
        /// For example, MaybeUninit<any BitwiseCopyable>.zeroInitialize() is fully initialized,
        /// but MaybeUninit<any ~BitwiseCopyable>.zeroInitialize() is not because it might be a reference or contains a reference.
        public static func zeroInitialize() -> Self {
            let result = Self()
            result.unsafelyInitialize { ptr in
                UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: UInt8.self).initialize(to: 0)
            }
            return result
        }
    }

    extension MaybeUninit {
        subscript<T>(dynamicMember member: KeyPath<Value, T>) -> T {
            value[keyPath: member]
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
            UnsafeMutablePointer<Value>(_rawAddress)
        }

        /// Initializes the value of the `MaybeUninit<Value>` instance.
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public func initialize(to initialValue: consuming Value) {
            Builtin.initialize(initialValue, _rawAddress)
        }

        /// Creates a new MaybeUninit<T> in an uninitialized state.
        /// This is useful for type
        @_transparent
        @_alwaysEmitIntoClient
        public init() {
            _rawAddress = Builtin.allocRaw(
                findByteCount(of: Value.self)._builtinWordValue,
                findAlignment(of: Value.self)._builtinWordValue)
            Builtin.bindMemory(_rawAddress, (1)._builtinWordValue, Value.self)
        }

        deinit {
            _ = _address.deinitialize(count: 1)
            Builtin.deallocRaw(_rawAddress, (-1)._builtinWordValue, (0)._builtinWordValue)
        }

        ///
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public consuming func take() -> Value {
            let value = _address.move()
            Builtin.deallocRaw(_rawAddress, (-1)._builtinWordValue, (0)._builtinWordValue)
            discard self
            return value
        }

        ///
        @_transparent
        @_alwaysEmitIntoClient
        public var value: Value {
            _read {
                yield _address.pointee
            }
            _modify {
                yield &_address.pointee
            }
        }

        /// Initialize the MaybeUninit's instance through an UnsafeMutablePointer
        /// - Parameter body: the closure that initializes the value
        /// - Returns: anything the body parameter returns
        public func unsafelyInitialize<T>(_ body: (UnsafeMutablePointer<Value>) throws -> T)
            rethrows
            -> T
        {
            try body(_address)
        }

    }

    extension MaybeUninit where Value: BitwiseCopyable {
        /// Creates a new MaybeUninit<Value> in an uninitialized state, then fills the memory with value  of 0.
        ///
        /// It depends on Value being zero initilizable which most BitwiseCopyable types are.
        /// For example, MaybeUninit<any BitwiseCopyable>.zeroInitialize() is fully initialized,
        /// but MaybeUninit<any ~BitwiseCopyable>.zeroInitialize() is not because it might be a reference or contains a reference.
        public static func zeroInitialize() -> Self {
            let result = Self()
            result.unsafelyInitialize { ptr in
                UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: UInt8.self).initialize(to: 0)
            }
            return result
        }
    }

    extension MaybeUninit {
        subscript<T>(dynamicMember member: KeyPath<Value, T>) -> T {
            value[keyPath: member]
        }
    }

#endif
