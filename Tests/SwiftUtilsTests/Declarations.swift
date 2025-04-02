enum SomeError: Swift.Error {
    case unknown
}

struct ExampleStruct: Equatable {

    var int: Int

    var string: String

    var arrayOfFloats: [Float]

    func someMethod() {
        print(self)
    }
}

class ExampleClass {
    var name = "Unknown"
    var age = 18
}

struct Pair<First: ~Copyable, Second: ~Copyable>: ~Copyable {
    var first: First
    var second: Second
}

extension Pair: Copyable where First: Copyable, Second: Copyable {}

extension Pair: BitwiseCopyable where First: BitwiseCopyable, Second: BitwiseCopyable {}
