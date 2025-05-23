import Builtin

/// Get the byte count of a specific type.
/// The byte count implied here is the type's actually size plus any
/// padding the type has
/// - Parameter type: the type whose byte count is needed
/// - Returns: the type's byte count value as an Int value
@usableFromInline
internal func findByteCount<T: ~Copyable>(of type: T.Type) -> Int {
    MemoryLayout<T>.stride
}

/// Get the alignment of a specific type
/// - Parameter type: the type whose alignment is needed
/// - Returns: the type's alignment value as an Int value
@usableFromInline
internal func findAlignment<T: ~Copyable>(of type: T.Type) -> Int {
    MemoryLayout<T>.alignment
}

/// Deinitialize a raw pointer and leaves it in an uninitialized state while returning the value
/// the pointer previously had
/// - Parameters:
///   - type: the metatype of which the raw pointer is to be deinitialized with
///   - pointer: the builtin raw pointer which is to be deinitialized
/// - Returns: the value the raw pointer previously contained
@usableFromInline
internal func takeFromRaw<T: ~Copyable>(of type: T.Type, pointer: Builtin.RawPointer) -> T {
    Builtin.take(pointer)
}

/// Initializes a raw pointer with the value passed in
/// - Parameters:
///   - value: the value used for initialized the raw pointer
///   - pointer: the builtin raw pointer to be initialized
@usableFromInline
internal func storeIntoRaw<T: ~Copyable>(_ value: consuming T, pointer: Builtin.RawPointer) {
    Builtin.initialize(consume value, pointer)
}

/// Assigns the value passed into raw pointer
/// - Parameters:
///   - value: the value used for assigning into the raw pointer
///   - pointer: the builtin raw pointer to be assigned to
@usableFromInline
internal func assignIntoRaw<T: ~Copyable>(_ value: consuming T, pointer: Builtin.RawPointer) {
    Builtin.assign(consume value, pointer)
}

/// Deallocates and also deinitializes the raw pointer
/// - Parameters:
///   - type: the metatype of which the raw pointer is to be deinitialized with
///   - pointer: the builtin raw pointer to be deallocated
/// - Returns: The value the raw pointer had
@usableFromInline
internal func deallocRaw<T: ~Copyable>(of type: T.Type, pointer: Builtin.RawPointer) -> T {
    let value: T = Builtin.take(pointer)
    Builtin.deallocRaw(pointer, (-1)._builtinWordValue, (0)._builtinWordValue)
    return value
}

/// Get the number of types a tuple value contains
/// - Parameter _: the tuple value metatype
/// - Returns: the number of types the tuple contains
@usableFromInline
internal func getTupleCount<each Value>(_: repeat (each Value).Type) -> Int {
    Int(Builtin.packLength((repeat each Value).self))
}

/// Creates a builtin raw pointer bound to a specific type
/// - Parameter type: the type's metatype
/// - Returns: a builtin raw pointer
@usableFromInline
internal func createRawPointer<T: ~Copyable>(_ type: T.Type = T.self) -> Builtin.RawPointer {
    let rawPointer: Builtin.RawPointer = Builtin.allocRaw(
        findByteCount(of: T.self)._builtinWordValue,
        findAlignment(of: T.self)._builtinWordValue)
    Builtin.bindMemory(rawPointer, (1)._builtinWordValue, T.self)
    return rawPointer
}

/// Creates a builtin raw pointer
/// - Parameters:
///   - byteCount: The byteCount
///   - alignment: The alignment
/// - Returns: a raw pointer unbound to any type
@usableFromInline
internal func createRawPointer(byteCount: Int, alignment: Int) -> Builtin.RawPointer {
    return Builtin.allocRaw(byteCount._builtinWordValue, alignment._builtinWordValue)
}

/// Iterates over generic parameter pack of metatypes and ceck if the expected metattype is exists in the pack
/// - Parameters:
///   - types: generic parameter pack of metatypes
///   - expected: the expected type metatype
/// - Returns: true if found else false
@usableFromInline
func iterateOverMetatypes<each Type, T>(of types: (repeat (each Type).Type), expected type: T.Type)
    -> Bool
{

    for meta in repeat (each types) {
        if type == meta {
            return true
        }
    }
    return false
}
