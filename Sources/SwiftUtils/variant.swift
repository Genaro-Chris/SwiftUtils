import Builtin

// Because of some limitations a generic parameter pack cannot be noncopyable
@frozen
public struct Variant<Value, each Item>: ~Copyable {

    @_alwaysEmitIntoClient
    internal let _rawAddress: Builtin.RawPointer

    // Current value's metatype
    @_alwaysEmitIntoClient
    internal var metatype: MetaTypeHolder<Any.Type>

    ///
    /// - Parameter value:
    @_transparent
    @_alwaysEmitIntoClient
    public init<T>(with value: consuming T) {
        var byteCount = findByteCount(of: Value.self)

        var metatype = MetaTypeHolder<Any.Type>.empty

        if T.self == Value.self {
            metatype = .sometype(Value.self)
        } else {
            for meta in repeat ((each Item).self) {
                // Ensure that only the type with largest bytecount is used to allocate the pointer
                byteCount = max(byteCount, findByteCount(of: meta))
                if meta == T.self {
                    metatype = .sometype(meta)
                }
            }
        }

        // Ensure that the argument's type is among the variant generic type parameter
        guard case .sometype(_) = metatype else {
            preconditionFailure(
                "Argument value's type isn't among one of the variant generic parameter pack types")
        }

        self.metatype = metatype
        self._rawAddress = Builtin.allocRaw(
            byteCount._builtinWordValue, findAlignment(of: T.self)._builtinWordValue)
        Builtin.bindMemory(_rawAddress, (1)._builtinWordValue, T.self)
        Builtin.initialize(value, _rawAddress)

    }

    deinit {

        switch metatype {

        case .empty: ()

        case .sometype(let someMetaType) where someMetaType == Value.self:
            // This ensures that we deinitialize the pointer with the correct type
            Variant.getPointer(of: Value.self, from: _rawAddress).deinitialize(count: 1)
            Builtin.deallocRaw(_rawAddress, (-1)._builtinWordValue, (0)._builtinWordValue)

        case .sometype(let someMetaType):
            for meta in repeat ((each Item).self) {
                if meta == someMetaType {
                    // This ensures that we deinitialize the pointer with the correct type
                    Variant.getPointer(of: meta, from: _rawAddress).deinitialize(count: 1)
                    Builtin.deallocRaw(_rawAddress, (-1)._builtinWordValue, (0)._builtinWordValue)
                }
            }
        }

    }

    ///
    /// - Parameters:
    ///   - type:
    ///   - value:
    /// - Returns:
    @_transparent
    @_alwaysEmitIntoClient
    public mutating func change<T>(_ type: T.Type = T.self, to value: consuming T) -> Any {

        switch metatype {

        case .empty: ()

        case .sometype(let someMetaType) where someMetaType == Value.self:
            let old_value = Variant.getPointer(of: Value.self, from: _rawAddress).move()
            metatype = .sometype(type)

            Builtin.bindMemory(_rawAddress, (1)._builtinWordValue, type)
            Builtin.initialize(value, _rawAddress)

            return old_value

        case .sometype(let someMetaType):

            for meta in repeat ((each Item).self) {
                if meta == someMetaType {
                    let old_value = Variant.getPointer(of: meta, from: _rawAddress).move()
                    metatype = .sometype(type)

                    Builtin.bindMemory(_rawAddress, (1)._builtinWordValue, type)
                    Builtin.initialize(value, _rawAddress)

                    return old_value
                }
            }
        }

        preconditionFailure(
            "Argument value's type isn't among one of the variant generic parameter pack types")

    }

    ///
    /// - Parameters:
    ///   - body:
    ///   - closures:
    /// - Throws:
    @_transparent
    @_alwaysEmitIntoClient
    public func visitThrows(
        _ body: (borrowing Value) throws -> Void, _ closures: repeat (borrowing each Item) throws -> Void
    ) throws {

        switch metatype {

        case .empty: ()

        case .sometype(let someMetaType) where someMetaType == Value.self:
            return try body(Variant.getPointer(from: _rawAddress).pointee)

        case .sometype(let someMetaType):
            for (funcBody, type) in repeat (each closures, (each Item).self) {
                if type == someMetaType {
                    return try funcBody(Variant.getPointer(of: type, from: _rawAddress).pointee)
                }
            }
        }

    }

    ///
    /// - Parameters:
    ///   - body:
    ///   - closures:
    @_transparent
    @_alwaysEmitIntoClient
    public func visit(_ body: (borrowing Value) -> Void, _ closures: repeat (borrowing each Item) -> Void) {
        switch metatype {

        case .empty: ()

        case .sometype(let someMetaType) where someMetaType == Value.self:
            return body(Variant.getPointer(from: _rawAddress).pointee)

        case .sometype(let someMetaType):
            for (funcBody, type) in repeat (each closures, (each Item).self) {
                if type == someMetaType {
                    return funcBody(Variant.getPointer(of: type, from: _rawAddress).pointee)
                }
            }
        }
    }

    ///
    /// - Parameters:
    ///   - typeOf:
    ///   - body:
    /// - Returns:
    @_transparent
    @_alwaysEmitIntoClient
    public func interact<Input, ReturnType>(
        as typeOf: Input.Type, _ body: (inout Input) throws -> ReturnType
    ) rethrows
        -> ReturnType
    {

        if case let .sometype(someType) = metatype {
            print("Type is \(someType) while argument is \(typeOf)")
        }

        switch metatype {

        case .empty: ()

        case .sometype(let someMetaType) where someMetaType == Value.self && someMetaType == typeOf:
            return try body(&Variant.getPointer(of: typeOf, from: _rawAddress).pointee)

        case .sometype(let someMetaType):
            print("Here: \(someMetaType)")
            for type in repeat (each Item).self {
                if type == someMetaType && type == typeOf {
                    return try body(&Variant.getPointer(of: typeOf, from: _rawAddress).pointee)
                }
            }

        }

        preconditionFailure(
            "Argument value's type isn't among one of the variant generic parameter pack types")

    }

    ///
    /// - Parameter body:
    /// - Returns:
    @_transparent
    @_alwaysEmitIntoClient
    public func interactAsAny<ReturnType>(_ body: (inout Any) throws -> ReturnType) rethrows
        -> ReturnType
    {
        return try body(&Variant.getPointer(from: _rawAddress).pointee)
    }

}

extension Variant {
    @_transparent
    @_alwaysEmitIntoClient
    internal static func getPointer<T>(of type: T.Type = T.self, from ptr: Builtin.RawPointer)
        -> UnsafeMutablePointer<T>
    {
        UnsafeMutablePointer<T>(ptr)
    }
}

extension Variant where Value: Copyable, repeat each Item: Copyable {
    ///
    /// - Parameter typeOf:
    /// - Returns:
    @_transparent
    @_alwaysEmitIntoClient
    public func get<T>(as typeOf: T.Type) -> T {

        switch metatype {

        case .empty: ()

        case .sometype(let someMetaType) where someMetaType == Value.self:
            return Variant.getPointer(of: typeOf, from: _rawAddress).pointee

        case .sometype(let someMetaType):
            for type in repeat (each Item).self {
                if type == someMetaType && type == typeOf {
                    return Variant.getPointer(of: T.self, from: _rawAddress).pointee
                }
            }
        }

        preconditionFailure(
            "Argument value's type isn't among one of the variant generic parameter pack types")
    }
}
