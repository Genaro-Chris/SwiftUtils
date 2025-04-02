import Builtin

@usableFromInline
internal func findByteCount<T: ~Copyable>(of type: T.Type = T.self) -> Int {
    MemoryLayout<T>.stride
}

@usableFromInline
internal func findAlignment<T: ~Copyable>(of type: T.Type = T.self) -> Int {
    MemoryLayout<T>.alignment
}

@usableFromInline
internal func takeFromRaw<T: ~Copyable>(of type: T.Type = T.self, _ ptr: Builtin.RawPointer) -> T {
    Builtin.take(ptr)
}

@usableFromInline
internal func storeIntoRaw<T: ~Copyable>(_ value: consuming T, _ ptr: Builtin.RawPointer) {
    Builtin.initialize(consume value, ptr)
}

@usableFromInline
internal
func getTupleCount<each Value>(_: repeat (each Value).Type) -> Int {
    Int(Builtin.packLength((repeat each Value).self))
}