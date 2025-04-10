///
@frozen
public struct AsyncFunction<each Input, Output> {

    @_alwaysEmitIntoClient
    internal let body: (repeat each Input) async -> Output

    ///
    /// - Parameter body:
    @_transparent
    @_alwaysEmitIntoClient
    public init(_ body: @escaping (repeat each Input) async -> Output) {
        self.body = body
    }

    ///
    /// - Parameter inputs:
    /// - Returns:
    @_transparent
    @_alwaysEmitIntoClient
    public func callAsFunction(_ inputs: repeat each Input) async -> Output {
        return await body(repeat each inputs)
    }

    ///
    /// - Parameter inputs:
    /// - Returns:
    @_transparent
    @_alwaysEmitIntoClient
    public func callAsFunction(_ inputs: (repeat each Input)) async -> Output {
        return await body(repeat each inputs)
    }
}

#if $TypedThrows || hasFeature(TypedThrows) || hasFeature(FullyTypedThrows)

    ///
    @frozen
    public struct AsyncThrowingFunction<each Input, Error: Swift.Error, Output> {

        @_alwaysEmitIntoClient
        internal let body: (repeat each Input) async throws(Error) -> Output

        ///
        /// - Parameter body:
        @_transparent
        @_alwaysEmitIntoClient
        public init(_ body: @escaping (repeat each Input) async throws(Error) -> Output) {
            self.body = body
        }

        ///
        /// - Parameter inputs:
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: repeat each Input) async throws(Error) -> Output {
            return try await body(repeat each inputs)
        }

        ///
        /// - Parameter inputs:
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: (repeat each Input)) async throws(Error) -> Output {
            return try await body(repeat each inputs)
        }
    }

#else

    ///
    @frozen
    public struct AsyncThrowingFunction<each Input, Output> {

        @_alwaysEmitIntoClient
        internal let body: (repeat each Input) async throws -> Output

        ///
        /// - Parameter body:
        @_transparent
        @_alwaysEmitIntoClient
        public init(_ body: @escaping (repeat each Input) async throws -> Output) {
            self.body = body
        }

        ///
        /// - Parameter inputs:
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: repeat each Input) async throws -> Output {
            return try await body(repeat each inputs)
        }

        ///
        /// - Parameter inputs:
        /// - Returns:
        @_transparent
        @_alwaysEmitIntoClient
        public func callAsFunction(_ inputs: (repeat each Input)) async throws -> Output {
            return try await body(repeat each inputs)
        }
    }

#endif
