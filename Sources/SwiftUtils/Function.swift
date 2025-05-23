/// A callable object
/// 
/// This construct provide a nominal interface to the swift's closure type
@frozen
public struct Function<each Input, Output> {

    @_alwaysEmitIntoClient
    internal let body: (repeat each Input) -> Output

    /// Initialize the function
    /// - Parameter body: closure to be called later
    @_transparent
    @_alwaysEmitIntoClient
    public init(_ body: @escaping (repeat each Input) -> Output) {
        self.body = body
    }

    /// calls the function
    /// - Parameter inputs: variadic arguments list of arbitrary types
    /// - Returns: whatever the function returns
    @_transparent
    @_alwaysEmitIntoClient
    public func callAsFunction(_ inputs: repeat each Input) -> Output {
        return body(repeat each inputs)
    }

    /// calls the function
    /// - Parameter inputs: tuple of arbitrary values
    /// - Returns: whatever the function returns
    @_transparent
    @_alwaysEmitIntoClient
    public func callAsFunction(_ inputs: (repeat each Input)) -> Output {
        return body(repeat each inputs)
    }
}
