import Builtin

@usableFromInline
enum MetaTypeHolder<T> {

    case empty
    case sometype(T)
}

@usableFromInline
func findByteCount<T: ~Copyable>(of type: T.Type = T.self) -> Int {
    return MemoryLayout<T>.size
}

@usableFromInline
func findByteCount<T: AnyObject>(of type: T.Type = T.self) -> Int {
    return MemoryLayout<T>.alignment * MemoryLayout<T>.stride
}

@usableFromInline
func findAlignment<T: ~Copyable>(of type: T.Type = T.self) -> Int {
    MemoryLayout<T>.alignment <= 16 ? 0 : MemoryLayout<T>.alignment
}
