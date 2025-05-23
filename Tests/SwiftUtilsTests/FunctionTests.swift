import Foundation
import Testing

@testable import Utilities

@Suite("Function Tests")
struct FunctionTests {

    @Test func closureFromFunction() {
        let closure = Function(exampleFunction)
        #expect(closure("Adam", 31) == "Adam is 31 years old")
    }

    @Test func closureWithTupleFromFunction() {
        let closure = Function(exampleFunction)
        #expect(closure(("Adam", 31)) == "Adam is 31 years old")
    }

    @Test
    func closure() {
        let shiftByteRightBy2 = { (parm: UInt8) -> UInt8 in
            return parm << 2
        }

        #expect(Function(shiftByteRightBy2)(38) == 152)
    }

    @Test
    func throwingClosure() throws {
        let closure = ThrowingFunction { () throws in
            throw SomeError.unknown
        }

        #expect(throws: (any Error).self) {
            try closure()
        }
    }

    @Test
    func throwingTypedErrorClosure() throws {
        let closure = ThrowingFunction { () throws(SomeError) in
            throw SomeError.unknown
        }

        #expect(throws: SomeError.self) {
            try closure()
        }
    }

    @Test
    func closureWithMultipleArgs() {
        let shiftByteRightBy2 = Function { (val: UInt8, parm: UInt8) -> UInt8 in
            return val << parm
        }

        #expect(shiftByteRightBy2((38, 2)) == 152)
    }

    @Test
    func throwingClosureWithMultipleArgs() throws {
        let closure = ThrowingFunction { (_: String, _: Int) throws(SomeError) in
            throw SomeError.unknown
        }

        #expect(throws: SomeError.self) {
            try closure(("", 9))
        }
    }

    @Test
    func asyncClosure() async {
        let innerClosure = { () async -> Void in () }

        let asyncClosure = AsyncFunction { (parm: UInt8) -> UInt8 in
            await innerClosure()
            return parm << 2
        }

        #expect(await asyncClosure(38) == 152)
    }

    @Test
    func asyncThrowingClosure() async throws {
        let shiftByteRightBy2 = AsyncThrowingFunction { (parm: UInt8) throws -> UInt8 in
            try await Task.sleep(for: .milliseconds(100))
            return parm << 2
        }

        #expect(try await shiftByteRightBy2(38) == 152)
    }

    @Test
    func asyncThrowingTypedErrorClosure() async throws {
        let closure = AsyncThrowingFunction { () throws(SomeError) in
            try? await Task.sleep(for: .milliseconds(100))
            throw SomeError.unknown
        }

        await #expect(throws: SomeError.self) {
            try await closure()
        }
    }


    @Test
    func asyncClosureWithMultipleArgs() async {
        let innerClosure = { () async -> Void in () }

        let asyncClosure = AsyncFunction { (val:UInt8, parm: UInt8) -> UInt8 in
            await innerClosure()
            return val << parm
        }

        #expect(await asyncClosure((38, 2)) == 152)
    }

    @Test
    func asyncThrowingClosureWithMultipleArgs() async throws {
        let shiftByteRightBy2 = AsyncThrowingFunction { (val:UInt8, parm: UInt8) throws -> UInt8 in
            try await Task.sleep(for: .milliseconds(100))
            return val << parm
        }

        #expect(try await shiftByteRightBy2((38, 2)) == 152)
    }
}
