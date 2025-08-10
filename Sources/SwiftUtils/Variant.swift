import Builtin

// Because of some limitations a generic parameter pack cannot have noncopyable type therefore
// Variant can not contain noncopyable types

/// This is a construct that can store a any value from a list of different types.
/// This is more like a type safe union.
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
    /// - Parameter with: the value to initialize with
    /// - Throws: if the argument's type is not among the variant generic parameter pack types 
    /// or if the number of types are less than two (2)
    @_transparent
    @_alwaysEmitIntoClient
    public init<T>(with value: consuming T) throws {

        guard getTupleCount(repeat (each Item).self) > 1 else {
            throw VariantError.invalidNumberOfTypes
        }

        guard iterateOverMetatypes(of: (repeat (each Item).self), expected: T.self) else {
            throw VariantError.argumentTypeNotFound
        }

        var byteCount: Int = 0
        var alignment: Int = 0

        var counter: Int = 0
        self.metatypeIndex = -1
        for meta in repeat ((each Item).self) {

            // Ensure that only the type with largest bytecount is used to allocate the pointer
            byteCount = max(byteCount, findByteCount(of: meta))
            // Ensure that only the type with largest alignment is used to allocate the pointer
            alignment = max(alignment, findAlignment(of: meta))

            if meta == T.self && self.metatypeIndex == -1 {
                self.metatypeIndex = counter
            }

            counter += 1
        }

        self.rawPointer = createRawPointer(byteCount: byteCount, alignment: alignment)

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

    /// Changes the value this variant instance has and returns the old value
    /// 
    /// - Parameters:
    ///   - resultType: the metatype of the old value
    ///   - to: the new value to change this variant type to
    /// - Returns: the old value but casted to the return type specified
    /// - Throws: if the argument's type or the return type is not among the variant generic parameter pack types 
    /// or either the argument's type or the return type is not the right type at the moment
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func changeAndReturning<Input, Result>(
        _ resultType: Result.Type = Result.self, to value: consuming Input
    ) throws -> Result {

        var counter: Int = 0
        var oldValue: Result!
        let index: Int = self.metatypeIndex
        var resultFound: Bool = false
        var found: Bool = false

        for meta in repeat ((each Item).self) {
            if counter == index && meta == resultType {
                // Deinitialize the raw pointer and return the value it had
                oldValue = takeFromRaw(of: resultType, pointer: self.rawPointer)
                resultFound = true
            }

            if Input.self == meta && !found {
                self.metatypeIndex = counter
                found.toggle()
            }

            counter += 1
        }

        guard resultFound else {
            if let oldValue {
                storeIntoRaw(oldValue, pointer: self.rawPointer)
            }
            throw VariantError.returnTypeNotFound
        }

        guard found else {
            if let oldValue {
                storeIntoRaw(oldValue, pointer: self.rawPointer)
            }
            throw VariantError.argumentTypeNotFound
        }

        storeIntoRaw(consume value, pointer: self.rawPointer)

        return oldValue

    }

    /// Changes the value this variant instance has and returns the old value
    /// 
    /// - Parameters:
    ///   - to: the new value to change this variant type to
    /// - Returns: the old value but casted to the return type specified
    /// - Throws: if the argument's type is not among the variant generic parameter pack types
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func change<Input>(to value: consuming Input) throws -> Any {

        var counter: Int = 0
        var oldValue: Any?
        let index: Int = self.metatypeIndex
        var found: Bool = false

        for meta in repeat ((each Item).self) {

            if counter == index {
                // Deinitialize the raw pointer and return the value it had
                oldValue = takeFromRaw(of: meta, pointer: self.rawPointer)
            }

            if Input.self == meta && !found {
                self.metatypeIndex = counter
                found.toggle()
            }

            counter += 1
        }

        guard found else {
            if let oldValue {
                storeIntoRaw(oldValue, pointer: self.rawPointer)
            }
            throw VariantError.argumentTypeNotFound
        }

        storeIntoRaw(consume value, pointer: self.rawPointer)

        return oldValue!

    }

    /// Iterates over a list of closures and calls the right one that is the 
    /// one with the correct parameter type
    /// - Parameter closures: list of the closures to call with the correct type this variant contains
    /// - Returns: whatever the closure with the correct type as its parameter type returns
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func visit<Result>(
        _ closures: repeat (inout each Item) -> Result
    ) -> Result {

        var counter: Int = 0
        for (funcBody, meta) in repeat (each closures, (each Item).self) {
            if counter == self.metatypeIndex {
                return funcBody(&self.getPointer(of: meta).pointee)
            }

            counter += 1
        }

        fatalError("Unreachable")
    }

    /// Iterates over a list of closures and calls the right one that is the 
    /// one with the correct parameter type
    /// - Parameter closures: list of the closures to call with the correct type this variant contains
    /// - Returns: whatever the closure with the correct type as its parameter type returns
    /// - Throws: any error the closure with the correct type as its parameter type returns
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func visitThrows<Result>(
        _ closures: repeat (inout each Item) throws -> Result
    ) throws -> Result {

        var counter: Int = 0
        for (funcBody, meta) in repeat (each closures, (each Item).self) {
            if counter == self.metatypeIndex {
                return try funcBody(&self.getPointer(of: meta).pointee)
            }

            counter += 1
        }

        fatalError("Unreachable")
    }

    /// Iterates over a list of closures and calls the right one that is the 
    /// one with the correct parameter type
    /// - Parameter closures: list of the closures to call with the correct type this variant contains
    /// - Returns: whatever the closure with the correct type as its parameter type returns
    @_transparent
    @_alwaysEmitIntoClient
    public func visit<Result>(
        _ closures: repeat (borrowing each Item) -> Result
    ) -> Result {

        var counter: Int = 0
        for (funcBody, meta) in repeat (each closures, (each Item).self) {
            if counter == self.metatypeIndex {
                return funcBody(self.getPointer(of: meta).pointee)
            }

            counter += 1
        }

        fatalError("Unreachable")
    }

    /// Iterates over a list of closures and calls the right one that is the 
    /// one with the correct parameter type
    /// - Parameter closures: list of the closures to call with the correct type this variant contains
    /// - Returns: whatever the closure with the correct type as its parameter type returns
    /// - Throws: any error the closure with the correct type as its parameter type returns
    @_transparent
    @_alwaysEmitIntoClient
    public func visitThrows<Result>(
        _ closures: repeat (borrowing each Item) throws -> Result
    ) throws -> Result {

        var counter: Int = 0
        for (funcBody, meta) in repeat (each closures, (each Item).self) {
            if counter == self.metatypeIndex {
                return try funcBody(self.getPointer(of: meta).pointee)
            }

            counter += 1
        }

        fatalError("Unreachable")
    }

    /// Call the closure if the type passed in the right one at the moment
    ///
    /// - Parameters:
    ///   - as: the type this variant value is of
    ///   - body: closure to call
    /// - Returns: anything the closure returns
    /// - Throws: any error the closure throws, if the type passed in is not correct type
    /// or if the argument's type is not among the variant generic parameter pack types
    @_transparent
    @_alwaysEmitIntoClient
    public func interact<Input, Result>(
        as type: Input.Type, _ body: (inout Input) throws -> Result
    ) throws
        -> Result
    {

        var counter: Int = 0
        var found: Bool = false

        for meta in repeat ((each Item).self) {
            if counter == self.metatypeIndex && meta == type {
                return try body(&self.getPointer(of: type).pointee)
            }

            if Input.self == meta && !found {
                found.toggle()
            }

            counter += 1
        }

        guard found else {
            throw VariantError.argumentTypeNotFound
        }

        throw VariantError.wrongTypeSupplied

    }

    /// Call the closure regardless of the type 
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
    /// Access this variant value via subscript using metatype as index
    ///
    /// If you are not sure, please use either `get(as:)` or `getIf(as:)` because this
    /// might fail at runtime if the argument's type is not among the variant generic parameter pack types
    ///
    /// - Parameter as: the type this variant value is of
    /// - Returns: the value if the type passed in is correct
    @_alwaysEmitIntoClient
    public subscript<T>(as type: T.Type) -> T {

        @_transparent
        _read {

            var counter: Int = 0
            var found: Bool = false

            for meta in repeat (each Item).self {
                if type == meta && self.metatypeIndex == counter {
                    yield self.getPointer(of: type).pointee
                    return
                }

                if type == meta && !found {
                    found.toggle()
                }

                counter += 1
            }

            guard found else {
                preconditionFailure(
                    "Argument metatype is not among the variant generic parameter pack types")
            }

            preconditionFailure(
                "Argument's value type is not the correct type for this variant instance")

        }

        @_transparent
        _modify {

            var counter: Int = 0
            var found: Bool = false
            for meta in repeat (each Item).self {
                if type == meta && self.metatypeIndex == counter {
                    yield &self.getPointer(of: type).pointee
                    return
                }

                if type == meta && !found {
                    found.toggle()
                }

                counter += 1
            }

            guard found else {
                preconditionFailure(
                    "Argument metatype is not among the variant generic parameter pack types")
            }

            preconditionFailure(
                "Argument's value type is not the correct type for this variant instance")
        }

    }
}

extension Variant {
    @usableFromInline
    internal func getPointer<T: ~Copyable>(of type: T.Type = T.self)
        -> UnsafeMutablePointer<T>
    {
        UnsafeMutablePointer<T>(self.rawPointer)
    }
}

extension Variant where repeat each Item: Copyable {

    /// Returns the value this instance has if the type passed in is the correct type
    /// - Parameter as: the metatype of this instance value's type
    /// - Returns: this instance value
    /// - Throws: if the type passed in is not correct type
    @_transparent
    @_alwaysEmitIntoClient
    public func get<T>(as type: T.Type) throws -> T {

        var counter: Int = 0
        var found: Bool = false

        for meta in repeat (each Item).self {
            if T.self == meta && self.metatypeIndex == counter {
                return self.getPointer(of: type).pointee
            }

            if type == meta && !found {
                found.toggle()
            }

            counter += 1
        }

        guard found else {
            throw VariantError.argumentTypeNotFound
        }

        throw VariantError.wrongTypeSupplied

    }

    /// Returns the value this instance has if the type is correct one otherwise nil
    /// - Parameter as: the metatype of this instance value's type
    /// - Returns: this instance value otherwise nil
    @_transparent
    @_alwaysEmitIntoClient
    public func getIf<T>(as type: T.Type) -> T? {

        var counter: Int = 0

        for meta in repeat (each Item).self {
            if T.self == meta && self.metatypeIndex == counter {
                return self.getPointer(of: type).pointee
            }

            counter += 1
        }

        return nil
    }
}
