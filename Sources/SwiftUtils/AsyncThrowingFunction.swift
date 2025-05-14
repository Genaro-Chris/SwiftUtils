#if $TypedThrows || hasFeature(TypedThrows) || hasFeature(FullyTypedThrows)

    /// An async throwing callable object
    ///
    /// This construct provide a nominal interface to the swift's async throwing closure type
    @frozen
    public struct AsyncThrowingFunction<each Input, Error: Swift.Error, Output> {

        @_alwaysEmitIntoClient
        internal let body: (repeat each Input) async throws(Error) -> Output

        /// Initialize the function
        /// - Parameter body: async throwing closure to be called later
        @_transparent
        @_alwaysEmitIntoClient
        public init(_ body: @escaping (repeat each Input) async throws(Error) -> Output) {
            self.body = body
        }

        /// calls the function
        /// - Parameter inputs: variadic arguments list of arbitrary types
        /// - Returns: whatever the function results
        /// - Throws: Any error the function throws
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: repeat each Input) async throws(Error) -> Output {
            return try await body(repeat each inputs)
        }

        /// calls the function
        /// - Parameter inputs: tuple of arbitrary values
        /// - Returns: whatever the function results
        /// - Throws: Any error the function throws
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: (repeat each Input)) async throws(Error) -> Output {
            return try await body(repeat each inputs)
        }
    }

#else

    /// An async throwing callable object
    ///
    /// This construct provide a nominal interface to the swift's async throwing closure type
    @frozen
    public struct AsyncThrowingFunction<each Input, Output> {

        @_alwaysEmitIntoClient
        internal let body: (repeat each Input) async throws -> Output

        /// Initialize the function
        /// - Parameter body: async throwing closure to be called later
        @_transparent
        @_alwaysEmitIntoClient
        public init(_ body: @escaping (repeat each Input) async throws -> Output) {
            self.body = body
        }

        /// calls the function
        /// - Parameter inputs: variadic arguments list of arbitrary types
        /// - Returns: whatever the function results
        /// - Throws: Any error the function throws
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: repeat each Input) async throws -> Output {
            return try await body(repeat each inputs)
        }

        /// calls the function
        /// - Parameter inputs: tuple of arbitrary values
        /// - Returns: whatever the function results
        /// - Throws: Any error the function throws
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: (repeat each Input)) async throws -> Output {
            return try await body(repeat each inputs)
        }
    }

#endif
