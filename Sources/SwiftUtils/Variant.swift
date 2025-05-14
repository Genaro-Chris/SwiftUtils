import Builtin

// Because of some limitations a generic parameter pack cannot have noncopyable type therefore
// Variant can't contain noncopyable types

/// This is a construct that can store a value of different types more like a type safe union.
///
/// This is done for searching from the list of types the one with the largest size and then using it to allocate memory for storing
/// value of any type from the list of types
@frozen
public struct Variant<each Item>: ~Copyable {

    @_alwaysEmitIntoClient
    internal let rawPointer: Builtin.RawPointer

    // Current value's metatype index in parameter pack
    @_alwaysEmitIntoClient
    internal var metatypeIndex: Int

    /// Initializes a Variant instance with the argument value passed in
    ///
    /// - Parameter value: the value to initialize with
    /// - Throws: if the argument's type is not among one of the variant generic parameter pack types
    @_transparent
    @_alwaysEmitIntoClient
    public init<T>(with value: consuming T) throws {

        guard getTupleCount(repeat (each Item).self) > 1 else {
            throw VariantError.invalidNumberOfTypes
        }

        var byteCount: Int = 0
        var alignment: Int = 0

        var index: Int = -1

        var counter: Int = 0
        for meta in repeat ((each Item).self) {

            // Ensure that only the type with largest bytecount is used to allocate the pointer
            byteCount = max(byteCount, findByteCount(of: meta))
            // Ensure that only the type with largest alignment is used to allocate the pointer
            alignment = max(alignment, findAlignment(of: meta))

            if meta == T.self && index == -1 {
                index = counter
            } else {
                counter += 1
            }
        }

        // Ensure that the argument's type is among the variant generic type parameter
        guard index != -1 else {
            throw VariantError.wrongTypeSupplied
        }

        self.metatypeIndex = index
        self.rawPointer = Builtin.allocRaw(
            byteCount._builtinWordValue, alignment._builtinWordValue)

        assignIntoRaw(consume value, pointer: rawPointer)

    }

    deinit {

        var counter: Int = 0
        for meta in repeat ((each Item).self) {
            if counter == self.metatypeIndex {
                // This ensures that the pointer is deinitialized and deallocated with the correct type
                _ = deallocRaw(of: meta, pointer: self.rawPointer)
                return
            }

            counter += 1
        }

    }

    /// If you are not sure, please use `change<T>(to:)`
    ///
    /// - Parameters:
    ///   - type: the metatype of the new type
    ///   - value: the new value to change this variant type to
    /// - Returns: the old value but casted to the return type specified
    /// - Throws: if the argument's type or the return type is not among one of the variant generic parameter pack types
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func changeAndReturning<T, Result>(
        _ type: T.Type = T.self, to value: consuming T
    ) throws
        -> Result
    {
        var counter: Int = 0
        var oldValue: Result?
        let oldIndex: Int = self.metatypeIndex
        var found: Bool = false
        var returnTypeFound: Bool = false

        for meta in repeat ((each Item).self) {
            if counter == oldIndex && meta == Result.self {
                // Deinitialize the raw pointer and return the value it had
                oldValue = takeFromRaw(of: meta, pointer: self.rawPointer) as? Result
            }

            if meta == Result.self && !returnTypeFound {
                returnTypeFound.toggle()
            }

            if type == meta && !found {
                found.toggle()
                self.metatypeIndex = counter
            }

            counter += 1
        }

        guard found else {
            // Reinitialize the raw pointer before throwing this error to avoid UB (Undefined Behaviour)
            storeIntoRaw(oldValue!, pointer: self.rawPointer)
            throw VariantError.argumentTypeNotFound
        }

        guard returnTypeFound else {
            // Reinitialize the raw pointer before throwing this error to avoid UB (Undefined Behaviour)
            storeIntoRaw(oldValue!, pointer: self.rawPointer)
            throw VariantError.returnTypeNotFound
        }

        storeIntoRaw(consume value, pointer: self.rawPointer)

        return oldValue!

    }

    ///
    /// - Parameters:
    ///   - value: the new value to change this variant type to
    /// - Returns: the old value but casted to the return type specified
    /// - Throws: if the argument's type is not among one of the variant generic parameter pack types
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func change<T>(_ type: T.Type = T.self, to value: consuming T) throws -> Any {

        var counter: Int = 0
        var oldValue: Any? = nil
        var found: Bool = false
        let oldIndex: Int = self.metatypeIndex

        for meta in repeat ((each Item).self) {
            if counter == oldIndex {
                // Deinitialize the raw pointer and return the value it had
                oldValue = takeFromRaw(of: meta, pointer: self.rawPointer)
            }

            if type == meta && !found {
                found.toggle()
                self.metatypeIndex = counter
            }

            counter += 1
        }

        guard found else {
            // Reinitialize the raw pointer before throwing this error to avoid UB (Undefined Behaviour)
            storeIntoRaw(oldValue!, pointer: self.rawPointer)
            throw VariantError.argumentTypeNotFound
        }

        storeIntoRaw(consume value, pointer: self.rawPointer)

        return oldValue!

    }

    ///
    /// - Parameters:
    ///   - closures: list of the closures to call with the correct type this variant contains
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func visit<Result>(
        _ closures: repeat (inout each Item) -> Result
    ) -> Result {

        var counter = 0
        for (funcBody, meta) in repeat (each closures, (each Item).self) {
            if counter == self.metatypeIndex {
                return funcBody(&self.getPointer(of: meta).pointee)
            } else {
                counter += 1
            }
        }

        fatalError("Unreachable")
    }

    ///
    ///
    /// - Parameters:
    ///   - closures: list of the closures to call with the correct type this variant contains
    /// - Throws: any error any of the closure throws
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func visitThrows<Result>(
        _ closures: repeat (inout each Item) throws -> Result
    ) throws -> Result {

        var counter = 0
        for (funcBody, meta) in repeat (each closures, (each Item).self) {
            if counter == self.metatypeIndex {
                return try funcBody(&self.getPointer(of: meta).pointee)
            } else {
                counter += 1
            }
        }

        fatalError("Unreachable")
    }

    ///
    /// - Parameters:
    ///   - closures: list of the closures to call with the correct type this variant contains
    @_transparent
    @_alwaysEmitIntoClient
    public func visit<Result>(
        _ closures: repeat (borrowing each Item) -> Result
    ) -> Result {

        var counter = 0
        for (funcBody, meta) in repeat (each closures, (each Item).self) {
            if counter == self.metatypeIndex {
                return funcBody(self.getPointer(of: meta).pointee)
            } else {
                counter += 1
            }
        }

        fatalError("Unreachable")
    }

    ///
    ///
    /// - Parameters:
    ///   - closures: list of the closures to call with the correct type this variant contains
    /// - Throws: any error any of the closure throws
    @_transparent
    @_alwaysEmitIntoClient
    public func visitThrows<Result>(
        _ closures: repeat (borrowing each Item) throws -> Result
    ) throws -> Result {

        var counter = 0
        for (funcBody, meta) in repeat (each closures, (each Item).self) {
            if counter == self.metatypeIndex {
                return try funcBody(self.getPointer(of: meta).pointee)
            } else {
                counter += 1
            }
        }

        fatalError("Unreachable")
    }

    ///
    /// If you are not sure, please use `interactAsAny(_:)`
    ///
    /// - Parameters:
    ///   - type: the suggest type this variant value is of
    ///   - body: closure to call
    /// - Returns: anything the closure returns
    /// - Throws: if the closure throws any error or if the suggested type is not correct type
    @_transparent
    @_alwaysEmitIntoClient
    public func interact<Input, Result>(
        as type: Input.Type, _ body: (inout Input) throws -> Result
    ) throws
        -> Result
    {

        guard
            let result = try iterateOverMetatypes(
                of: (repeat (each Item).self), expected: type, index: self.metatypeIndex,
                { meta in
                    return try body(&self.getPointer(of: meta).pointee)
                })
        else {
            throw VariantError.wrongTypeSupplied
        }

        return result

    }

    ///
    ///   - body: closure to call
    /// - Returns: anything the closure returns
    /// - Throws: if the closure throws any error
    @_transparent
    @_alwaysEmitIntoClient
    public func interactAsAny<Result>(_ body: (inout Any) throws -> Result) rethrows
        -> Result
    {
        return try body(&self.getPointer().pointee)
    }

}

extension Variant {
    @usableFromInline
    internal func getPointer<T>(of type: T.Type = T.self)
        -> UnsafeMutablePointer<T>
    {
        UnsafeMutablePointer<T>(self.rawPointer)
    }
}

extension Variant where repeat each Item: Copyable {

    /// If you are not sure, please use `getIf(as:)
    ///
    /// - Parameter type: the metatype of this instance value's type
    /// - Returns: this instance value
    /// - Throws: if the suggested type is not correct type
    @_transparent
    @_alwaysEmitIntoClient
    public func get<T>(as type: T.Type) throws -> T {

        guard
            let result = iterateOverMetatypes(
                of: (repeat (each Item).self), expected: type, index: self.metatypeIndex,
                { meta in
                    return self.getPointer(of: meta).pointee
                })
        else {
            throw VariantError.wrongTypeSupplied
        }

        return result

    }

    ///
    ///
    /// - Parameter type: the metatype of this instance value's type
    /// - Returns: this instance value
    @_transparent
    @_alwaysEmitIntoClient
    public func getIf<T>(as type: T.Type) -> T? {

        return iterateOverMetatypes(
            of: (repeat (each Item).self), expected: type, index: self.metatypeIndex
        ) { meta in
            return self.getPointer(of: meta).pointee
        }
    }
}
