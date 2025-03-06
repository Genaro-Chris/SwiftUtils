import XCTest

@testable import Utilities

struct ExampleStruct {

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

#if canImport(Testing)

    import Testing

    @Suite("Utilities Tests")
    struct SwiftUtilsTests {

        @Test
        func maybeUninitZeroInitialize() {
            var zero = MaybeUninit<Pair<Duration, Int128>>.zeroInitialize()

            print("Zero value: \(zero.value)")

            typealias Ex<T: BitwiseCopyable, U: BitwiseCopyable, R> = (inout Pair<T, U>) -> R

            let ex: Ex<Duration, Int128, Void> = { pair in
                pair.first = Duration.seconds(1)
                pair.second = 123
            }

            ex(&zero.value)

            print("Zero value: \(zero.value)")

            #expect(zero.first == .seconds(1))

            #expect(zero.second == 123)
        }

        @Test
        func maybeUninit() {
            let maybe = MaybeUninit<ExampleStruct>()

            if true {
                maybe.initialize(
                    to: ExampleStruct(
                        int: 23, string: "String", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))
            }

            #expect(maybe.int == 23)

            let value = maybe.take()

            #expect(value.string == "String")
        }

        @Test
        func variant() {
            var variantValue = Variant<Int, String, [Float], ExampleClass>(with: "String")

            variantValue.visit(
                { (int: Int) in
                    print(int)
                },
                { (string: String) in
                    print(string)
                },
                { (array: [Float]) in
                    print(array)
                },
                { (object: ExampleClass) in
                    print(object)
                }
            )

            variantValue.interact(as: String.self) { $0 = "Variant in Swift" }

            #expect(variantValue.get(as: String.self) == "Variant in Swift")

            let old_value = variantValue.change(to: 25)

            print("Old value: \(old_value)")

            variantValue.interact(as: Int.self) {
                $0 += 25
                $0 *= 2
            }

            #expect(variantValue.get(as: Int.self) == 100)

        }
    }

#else

    final class SwiftUtilsTests: XCTestCase {

        func test_maybeUninitZeroInitialize() {
            var zero = MaybeUninit<Pair<Duration, Int128>>.zeroInitialize()

            print("Zero value: \(zero.value)")

            typealias Ex<T: BitwiseCopyable, U: BitwiseCopyable, R> = (inout Pair<T, U>) -> R

            let ex: Ex<Duration, Int128, Void> = { pair in
                pair.first = Duration.seconds(1)
                pair.second = 123
            }

            ex(&zero.value)

            print("Zero value: \(zero.value)")

            XCTAssert(zero.first == .seconds(1))

            XCTAssert(zero.second == 123)
        }

        func test_maybeUninit() {
            let maybe = MaybeUninit<ExampleStruct>()

            if true {
                maybe.initialize(
                    to: ExampleStruct(
                        int: 23, string: "String", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))
            }

            XCTAssert(maybe.int == 23)

            let value = maybe.take()

            XCTAssert(value.string == "String")
        }

        func test_variant() {
            var variantValue = Variant<Int, String, [Float], ExampleClass>(with: "String")

            variantValue.visit(
                { (int: Int) in
                    print(int)
                },
                { (string: String) in
                    print(string)
                },
                { (array: [Float]) in
                    print(array)
                },
                { (object: ExampleClass) in
                    print(object)
                }
            )

            variantValue.interact(as: String.self) { $0 = "Variant in Swift" }

            XCTAssert(variantValue.get(as: String.self) == "Variant in Swift")

            let old_value = variantValue.change(to: 25)

            print("Old value: \(old_value)")

            variantValue.interact(as: Int.self) {
                $0 += 25
                $0 *= 2
            }

            XCTAssert(variantValue.get(as: Int.self) == 100)

        }

    }

#endif
