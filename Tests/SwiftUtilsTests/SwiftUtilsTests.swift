import Foundation
import Testing

@testable import Utilities

@Suite("Utilities Tests")
struct SwiftUtilsTests {

    @Test
    func maybeUninitZeroInitialize() {
        var zero = MaybeUninit<Pair<Duration, Int128>>.zeroInitialize()

        typealias Ex<T: BitwiseCopyable, U: BitwiseCopyable, R> = (inout Pair<T, U>) -> R

        let ex: Ex<Duration, Int128, Void> = { pair in
            pair.first = Duration.seconds(1)
            pair.second = 123
        }

        ex(&zero.value)

        #expect(zero.first == .seconds(1))

        #expect(zero.second == 123)
    }

    @Test
    func maybeUninit() {
        var maybe = MaybeUninit<ExampleStruct>()

        if true {
            maybe.initialize(
                to: ExampleStruct(
                    int: 23, string: "String", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))
        }

        maybe.value.someMethod()

        maybe.string = "Hello"

        #expect(maybe.int == 23)
        #expect(maybe.string == "Hello")

        let value = maybe.take()

        #expect(
            value == ExampleStruct(int: 23, string: "Hello", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))

    }
}