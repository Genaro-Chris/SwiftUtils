import Utilities

enum SomeError: Swift.Error {
    case unknown
}

enum NoncopyableEnum: ~Copyable {

    case a, b, c
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
    var name: String
    var age: Int

    init(name: String = "Unknown", age: Int = 18) {
        self.name = name
        self.age = age
    }
}

struct Pair<First: ~Copyable, Second: ~Copyable>: ~Copyable {
    var first: First
    var second: Second
}

extension Pair: Copyable where First: Copyable, Second: Copyable {}

extension Pair: BitwiseCopyable where First: BitwiseCopyable, Second: BitwiseCopyable {}

func exampleFunction(name: String, age: Int) -> String {
    "\(name) is \(age) years old"
}