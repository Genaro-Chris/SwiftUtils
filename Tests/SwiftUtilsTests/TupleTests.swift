import Foundation
import Testing

@testable import Utilities

@Suite("Tuple Tests")
struct TupleTests {
    @Test func tuple() {
        let tuple = Tuple(by: "", 12, [""])
        #expect(tuple.count == 3)
        #expect(tuple.tuple == ("", 12, [""]))
    }

    @Test func anotherTuple() {
        let tuple = Tuple(with: ("", 12, [9.65]))
        #expect(tuple.count == 3)
        #expect(tuple.tuple == ("", 12, [9.65]))
    }

    @Test func indexTuple() {
        var tuple = Tuple(by: 1, 0.4, Float(73), "Hello", SomeError.unknown)
        tuple.2 = Float(2933.74)
        #expect(tuple.2 == Float(2933.74))
    }

    @Test func tuplePattern() {
        let tuple: Tuple<Int, Double, Float, String, Bool> = Tuple(
            by: 1, 0.4, Float(73), "Hello", false)

        #expect(tuple ~= (1, 0.4, Float(73), "Hello", false))
    }

    @Test func anotherTuplePattern() {
        let tuple: Tuple<Int, Double, Float, String, Bool> = Tuple(
            by: 1, 0.4, Float(73), "Hello", false)

        #expect((1, 0.4, Float(73), "Hello", false) ~= tuple)
    }

    @Test func tupleEquatable() {
        let tuple: Tuple<Int, Double, Float, String, Bool> = Tuple(
            by: 1, 0.4, Float(73), "Hello", false)

        #expect(tuple != Tuple(by: 193, 856.4, Float(590), "World", true))
    }

    @Test func tupleWithAnyObject() {
        let tuple = Tuple(by: 1, 0.4, ExampleClass(), "Hello", SomeError.unknown)
        tuple.2.name = "Programmer"
        tuple.2.age = 24
        #expect(tuple.2.age == 24)
        #expect(tuple.2.name == "Programmer")
    }
}
