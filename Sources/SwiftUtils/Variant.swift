import Builtin

// Because of some limitations a generic parameter pack cannot be noncopyable therefore
// Variant can't contain noncopyable type
@frozen
public struct Variant<Value, each Item>: ~Copyable {

    @_alwaysEmitIntoClient
    internal let _rawAddress: Builtin.RawPointer

    // Current value's metatype index in parameter pack
    @_alwaysEmitIntoClient
    internal var metatypeIndex: Int

    /// Initializes a Variant instance
    ///
    /// Warning: might fail at runtime if the argument's type is not among one of the variant generic parameter pack types
    /// - Parameter value: the value to initialize with
    @_transparent
    @_alwaysEmitIntoClient
    public init<T>(with value: consuming T) {
        var byteCount = findByteCount(of: Value.self)
        var alignment = findAlignment(of: Value.self)

        var index: Int = -1

        if T.self == Value.self {
            index = 0
        }

        var counter: Int = 1
        for meta in repeat ((each Item).self) {
            if meta == T.self && index == -1 {
                index = counter
            }

            defer {
                counter += 1
            }

            // Ensure that only the type with largest bytecount is used to allocate the pointer
            byteCount = max(byteCount, findByteCount(of: meta))
            // Ensure that only the type with largest alignment is used to allocate the pointer
            alignment = max(alignment, findAlignment(of: meta))
        }

        // Ensure that the argument's type is among the variant generic type parameter
        precondition(
            index != -1,
            "Argument value's type isn't among one of the variant generic parameter pack types")

        self.metatypeIndex = index
        self._rawAddress = Builtin.allocRaw(
            byteCount._builtinWordValue, alignment._builtinWordValue)

        Builtin.initialize(consume value, _rawAddress)

    }

    deinit {

        switch metatypeIndex {

        case 0:
            // This ensures that we deinitialize the pointer with the correct type
            self.getPointer(of: Value.self).deinitialize(count: 1)
            Builtin.deallocRaw(self._rawAddress, (-1)._builtinWordValue, (0)._builtinWordValue)

        default:
            var counter = 1
            for meta in repeat ((each Item).self) {
                defer {
                    counter += 1
                }

                if counter == metatypeIndex {
                    // This ensures that we deinitialize the pointer with the correct type
                    self.getPointer(of: meta).deinitialize(count: 1)
                    Builtin.deallocRaw(
                        self._rawAddress, (-1)._builtinWordValue, (0)._builtinWordValue)
                    return
                }
            }
        }

    }

    /// If you are not sure, please use `change<T>(to:)`
    ///
    /// Warning: might fail at runtime if the argument's type or the return type is not among one of the variant generic parameter pack types
    /// - Parameters:
    ///   - type: the metatype of the new type
    ///   - value: the new value to change this variant type to
    /// - Returns: the old value but casted to the return type specified
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func changeAndReturning<T, ReturnType>(
        _ typeOf: T.Type = T.self, to value: consuming T
    )
        -> ReturnType
    {
        var counter: Int = 1
        var oldValue: Any!
        let oldIndex = self.metatypeIndex
        var found = false
        var returnTypeFound = false

        switch oldIndex {

        case 0:
            oldValue = takeFromRaw(of: Value.self, self._rawAddress)

            if Value.self == ReturnType.self {
                returnTypeFound.toggle()
            }

            if typeOf == Value.self {
                self.metatypeIndex = 0
                found.toggle()
            } else {
                for meta in repeat ((each Item).self) {
                    defer { counter += 1 }

                    if meta == ReturnType.self && !returnTypeFound {
                        returnTypeFound.toggle()
                    }

                    if meta == typeOf && !found {
                        self.metatypeIndex = counter
                        found.toggle()
                    }
                }

            }

        default:

            if Value.self == ReturnType.self {
                returnTypeFound.toggle()
            }

            if Value.self == typeOf {
                self.metatypeIndex = 0
                found.toggle()
            }

            for meta in repeat ((each Item).self) {
                defer {
                    counter += 1
                }

                if counter == oldIndex {
                    oldValue = takeFromRaw(of: meta, self._rawAddress)
                }

                if meta == ReturnType.self && !returnTypeFound {
                    returnTypeFound.toggle()
                }

                if typeOf == meta && !found {
                    found.toggle()
                    self.metatypeIndex = counter
                }

            }

        }

        guard found else {
            preconditionFailure(
                "Argument value's type isn't among the variant generic parameter pack types"
            )
        }

        guard returnTypeFound else {
            preconditionFailure(
                "Return type supplied isn't among the variant generic parameter pack types"
            )
        }

        storeIntoRaw(consume value, self._rawAddress)

        return oldValue as! ReturnType

    }

    ///
    /// Warning: might fail at runtime if the argument's type is not among one of the variant generic parameter pack types
    /// - Parameters:
    ///   - value: the new value to change this variant type to
    /// - Returns: the old value but casted to the return type specified
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func change<T>(_ typeOf: T.Type = T.self, to value: consuming T) -> Any {

        var counter: Int = 1
        var oldValue: Any! = nil
        var found = false
        let oldIndex: Int = self.metatypeIndex

        switch oldIndex {

        case 0:
            oldValue = takeFromRaw(of: Value.self, self._rawAddress)

            if typeOf == Value.self {
                self.metatypeIndex = 0
                found.toggle()
            } else {
                for meta in repeat ((each Item).self) {
                    defer {
                        counter += 1
                    }

                    if meta == typeOf {
                        self.metatypeIndex = counter
                        found.toggle()
                        break
                    }
                }

            }

        default:

            if Value.self == typeOf {
                self.metatypeIndex = 0
                found.toggle()
            }

            for meta in repeat ((each Item).self) {

                defer {
                    counter += 1
                }

                if counter == oldIndex {
                    oldValue = takeFromRaw(of: meta, self._rawAddress)

                }

                if typeOf == meta && !found {
                    found.toggle()
                    self.metatypeIndex = counter
                }
            }

        }

        guard found else {
            preconditionFailure(
                "Argument value's type isn't among the variant generic parameter pack types"
            )
        }

        storeIntoRaw(consume value, self._rawAddress)

        return oldValue!

    }

    ///
    /// - Parameters:
    ///   - body: a closure to call if this instance value is of type `Value`
    ///   - closures: one of the closures to call if this instance value is not of type `Value`
    @_transparent
    @_alwaysEmitIntoClient
    public func visit(
        _ body: (borrowing Value) -> Void, _ closures: repeat (borrowing each Item) -> Void
    ) {

        switch self.metatypeIndex {

        case 0:
            body(self.getPointer(of: Value.self).pointee)

        default:
            var counter = 1
            for (funcBody, meta) in repeat (each closures, (each Item).self) {
                defer {
                    counter += 1
                }

                if counter == self.metatypeIndex {
                    funcBody(self.getPointer(of: meta).pointee)
                }
            }
        }

    }

    ///
    ///
    /// - Parameters:
    ///   - body: a closure to call if this instance value is of type `Value`
    ///   - closures: one of the closures to call if this instance value is not of type `Value`
    /// - Throws: any error any of the closure throws
    @_transparent
    @_alwaysEmitIntoClient
    public func visitThrows(
        _ body: (borrowing Value) throws -> Void,
        _ closures: repeat (borrowing each Item) throws -> Void
    ) throws {

        switch self.metatypeIndex {

        case 0:
            try body(self.getPointer(of: Value.self).pointee)

        default:
            var counter = 1
            for (funcBody, meta) in repeat (each closures, (each Item).self) {
                defer {
                    counter += 1
                }

                if counter == self.metatypeIndex {
                    try funcBody(self.getPointer(of: meta).pointee)
                }
            }
        }

    }

    ///
    /// If you are not sure, please use `interactAsAny(_:)`
    /// 
    /// Warning: might fail at runtime if the suggested type is not correct type
    ///
    /// - Parameters:
    ///   - typeOf: the suggest type this variant value is of
    ///   - body: closure to call
    /// - Returns: anything the closure returns
    /// - Throws: if the closure throws any error
    @_transparent
    @_alwaysEmitIntoClient
    public func interact<Input, ReturnType>(
        as typeOf: Input.Type, _ body: (inout Input) throws -> ReturnType
    ) rethrows
        -> ReturnType
    {

        if typeOf == Value.self {
            return try body(&self.getPointer(of: typeOf).pointee)
        } else {
            var counter = 1
            for meta in repeat (each Item).self {
                defer {
                    counter += 1
                }

                if counter == self.metatypeIndex && meta == typeOf {
                    return try body(&self.getPointer(of: typeOf).pointee)
                }
            }

        }

        preconditionFailure(
            "Argument value's type isn't among the variant generic parameter pack types")

    }

    ///
    ///   - body: closure to call
    /// - Returns: anything the closure returns
    /// - Throws: if the closure throws any error
    @_transparent
    @_alwaysEmitIntoClient
    public func interactAsAny<ReturnType>(_ body: (inout Any) throws -> ReturnType) rethrows
        -> ReturnType
    {
        return try body(&self.getPointer().pointee)
    }

}

extension Variant {
    @usableFromInline
    internal func getPointer<T>(of typeOf: T.Type = T.self)
        -> UnsafeMutablePointer<T>
    {
        UnsafeMutablePointer<T>(self._rawAddress)
    }
}

extension Variant where Value: Copyable, repeat each Item: Copyable {
    /// 
    /// Warning: might fail at runtime if the suggested type is not correct type
    /// 
    /// - Parameter typeOf: the metatype of this instance value's type
    /// - Returns: this instance value
    @_transparent
    @_alwaysEmitIntoClient
    public func get<T>(as typeOf: T.Type) -> T {

        if typeOf == Value.self {
            return self.getPointer(of: typeOf).pointee
        } else {
            var counter: Int = 1
            for meta in repeat (each Item).self {
                defer {
                    counter += 1
                }

                if counter == self.metatypeIndex && meta == typeOf {
                    return self.getPointer(of: typeOf).pointee
                }
            }

        }

        preconditionFailure(
            "Argument value's type isn't among the variant generic parameter pack types")
    }
}
