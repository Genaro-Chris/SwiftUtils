import Foundation
import Testing

@testable import Utilities

@Suite("MaybeUninit Tests")
struct MaybeUninitTests {

    @Test
    func maybeUninitZeroInitialize() {
        let zero = MaybeUninit<Pair<Duration, Int128>>.zeroInitialize()

        #expect(zero.first == .seconds(0))

        #expect(zero.second == 0)
    }

    @Test
    func maybeUninit() {
        var maybe = MaybeUninit<ExampleStruct>()

        maybe.initialize(to: ExampleStruct(int: 23, string: "String", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))

        maybe.value.someMethod()

        maybe.string = "Hello"

        #expect(maybe.int == 23)
        #expect(maybe.string == "Hello")

        #expect(maybe.take() == ExampleStruct(int: 23, string: "Hello", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))

    }

    @Test func maybeUninitNoncopyable() {
        var maybe = MaybeUninit<NoncopyableEnum>()

        maybe.initialize(to: .c)

        switch maybe.value {

        case .c: ()

        default: Issue.record("It should be the .c case")

        }

        maybe.value = .b

        #expect(maybe.value == .b)
    }

    @Test func maybeUninitUseAfterTake() {
        var maybe = MaybeUninit<ExampleStruct>()

        maybe.initialize(to: ExampleStruct(int: 6, string: "String", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))

        #expect(maybe.take() == ExampleStruct(int: 6, string: "String", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))

        maybe = MaybeUninit()

        maybe.initialize(to: ExampleStruct(int: 23, string: "Hello", arrayOfFloats: [0.1, 0.4, 0.7, 0.8]))

        #expect(maybe.int == 23)
        #expect(maybe.string == "Hello")
    }
}
