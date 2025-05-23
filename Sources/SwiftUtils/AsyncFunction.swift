/// An async callable object
/// 
/// This construct provide a nominal interface to the swift's async closure type
@frozen
public struct AsyncFunction<each Input, Output> {

    @_alwaysEmitIntoClient
    internal let body: (repeat each Input) async -> Output

    /// Initialize the async function
    /// - Parameter body: async closure to be called later
    @_transparent
    @_alwaysEmitIntoClient
    public init(_ body: @escaping (repeat each Input) async -> Output) {
        self.body = body
    }

    /// calls the function
    /// - Parameter inputs: variadic arguments list of arbitrary types
    /// - Returns: whatever the function returns
    @_transparent
    @_alwaysEmitIntoClient
    public func callAsFunction(_ inputs: repeat each Input) async -> Output {
        return await body(repeat each inputs)
    }

    /// calls the function
    /// - Parameter inputs: tuple of arbitrary values
    /// - Returns: whatever the function returns
    @_transparent
    @_alwaysEmitIntoClient
    public func callAsFunction(_ inputs: (repeat each Input)) async -> Output {
        return await body(repeat each inputs)
    }
}
