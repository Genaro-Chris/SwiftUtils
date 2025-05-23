#if $TypedThrows || hasFeature(TypedThrows) || hasFeature(FullyTypedThrows)
    /// A throwing callable object
    /// 
    /// This construct provide a nominal interface to the swift's throwing closure type
    @frozen
    public struct ThrowingFunction<each Input, Error: Swift.Error, Output> {

        @_alwaysEmitIntoClient
        internal let body: (repeat each Input) throws(Error) -> Output

        /// Initialize the throwing function
        /// - Parameter body: throwing closure to be called later
        @_transparent
        @_alwaysEmitIntoClient
        public init(_ body: @escaping (repeat each Input) throws(Error) -> Output) {
            self.body = body
        }

        /// calls the function
        /// - Parameter inputs: variadic arguments list of arbitrary types
        /// - Returns: whatever the function returns
        /// - Throws: Any error the function throws
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: repeat each Input) throws(Error) -> Output {
            return try body(repeat each inputs)
        }

        /// calls the function
        /// - Parameter inputs: tuple of arbitrary values
        /// - Returns: whatever the function returns
        /// - Throws: Any error the function throws
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: (repeat each Input)) throws(Error) -> Output {
            return try body(repeat each inputs)
        }
    }
#else
    /// A throwing callable object
    /// 
    /// This construct provide a nominal interface to the swift's throwing closure type
    @frozen
    public struct ThrowingFunction<each Input, Output> {

        @_alwaysEmitIntoClient
        internal let body: (repeat each Input) throws -> Output

        /// Initialize the throwing function
        /// - Parameter body: throwing closure to be called later
        @_transparent
        @_alwaysEmitIntoClient
        public init(_ body: @escaping (repeat each Input) throws -> Output) {
            self.body = body
        }

        /// calls the function
        /// - Parameter inputs: variadic arguments list of arbitrary types
        /// - Returns: whatever the function returns
        /// - Throws: Any error the function throws
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: repeat each Input) throws -> Output {
            return try body(repeat each inputs)
        }

        /// calls the function
        /// - Parameter inputs: tuple of arbitrary values
        /// - Returns: whatever the function returns
        /// - Throws: Any error the function throws
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: (repeat each Input)) throws -> Output {
            return try body(repeat each inputs)
        }
    }

#endif
