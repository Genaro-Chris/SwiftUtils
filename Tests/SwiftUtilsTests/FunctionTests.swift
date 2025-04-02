import Foundation
import Testing

@testable import Utilities

@Suite("Function Tests")
struct FunctionTests {

    @Test
    func closure() {
        let shiftByteRightBy2 = Function { (parm: UInt8) -> UInt8 in
            return parm << 2
        }

        #expect(shiftByteRightBy2(38) == 152)
    }

    @Test
    func throwingClosure() throws {
        let closure = ThrowingFunction { () throws(SomeError) in
            throw SomeError.unknown
        }

        #expect(throws: SomeError.self) {
            try closure()
        }
    }

    @Test
    func asyncClosure() async {
        let innerCLosure = { () async -> Void in () }

        let asyncClosure = AsyncFunction { (parm: UInt8) -> UInt8 in
            await innerCLosure()
            return parm << 2
        }

        #expect(await asyncClosure(38) == 152)
    }

    @Test
    func asyncThrowingClosure() async throws {
        let shiftByteRightBy2 = AsyncThrowingFunction { (parm: UInt8) throws -> UInt8 in
            try await Task.sleep(for: .seconds(1))
            return parm << 2
        }

        #expect(try await shiftByteRightBy2(38) == 152)
    }

}
