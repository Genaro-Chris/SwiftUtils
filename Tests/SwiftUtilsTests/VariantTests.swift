import Foundation
import Testing

@testable import Utilities

@Suite("Variant Tests")
struct VariantTests {
    @Test
    func variant() throws {
        var variantValue: Variant<ExampleClass, Int, String, [Float]> = try Variant(with: "String")

        variantValue.visit(
            { (object: ExampleClass) in
                print(object)
            },
            { (int: Int) in
                print(int)
            },
            { (string: String) in
                print(string)
            },
            { (array: [Float]) in
                print(array)
            }
        )

        try variantValue.interact(as: String.self) { $0 = "Variant in Swift" }

        let oldValue: String = try variantValue.get(as: String.self)

        #expect(oldValue == "Variant in Swift")

        _ = try variantValue.change(to: 25)

        try variantValue.interact(as: Int.self) {
            $0 += 25
            $0 *= 2
        }

        #expect(try variantValue.get(as: Int.self) == 100)

        _ = try variantValue.change(to: ExampleClass())

    }

    @Test
    func anotherVariant() throws {
        var variantValue = try Variant<Int, String, [Float], ExampleClass>(with: 123)

        try variantValue.visitThrows(
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

        try variantValue.interact(as: Int.self) { $0 = 123 }

        #expect(try variantValue.get(as: Int.self) == 123)

        _ = try variantValue.change(to: 99)

        let oldValue: Int = try variantValue.changeAndReturning(to: [Float(253.89)])

        #expect(oldValue == 99)

        try variantValue.interact(as: [Float].self) {
            $0[0] += 25
            $0[0] *= 2
        }

        #expect(try variantValue.get(as: [Float].self) == [557.78])

        _ = try variantValue.changeAndReturning([Float].self, to: "Variant")

        _ = try variantValue.change(to: ExampleClass())

    }

    @Test func variantWrongTypeSupplied() throws {

        let variantValue = try Variant<Int, String, [Float], ExampleClass>(with: 123)

        #expect(throws: VariantError.wrongTypeSupplied) {
            try variantValue.interact(as: String.self) {
                #expect("" == $0)
            }
            
        }
    }

    @Test func variantReturntypeNotFound() throws {

        var variantValue = try Variant<Int, String, [Float], ExampleClass>(with: 123)

        #expect(throws: VariantError.returnTypeNotFound) {
            let newValue: Double = try variantValue.changeAndReturning(Double.self, to: "New Value")
            #expect(123.0 == newValue)
        }
    }

    @Test func variantVisitInout() throws {
        var variantValue = try Variant<Int, String, [Float], ExampleClass>(with: 123)

        #expect(try variantValue.get(as: Int.self) == 123)

        variantValue.visit(
            { (int: inout Int) in
                int *= 2
                print(int)
            },
            { (string: inout String) in
                string += "World"
                print(string)
            },
            { (array: inout [Float]) in
                array.append(contentsOf: [Float(2)])
                print(array)
            },
            { (object: inout ExampleClass) in
                object = ExampleClass()
                print(object)
            }
        )

        #expect(try variantValue.get(as: Int.self) == 246)

        _ = try variantValue.change(to: 746)

        let oldValue: Int = try variantValue.changeAndReturning(to: [Float(253.89)])

        #expect(oldValue == 746)

        try variantValue.interact(as: [Float].self) {
            $0[0] += 25
            $0[0] *= 2
        }

        #expect(try variantValue.get(as: [Float].self) == [557.78])

        _ = try variantValue.changeAndReturning([Float].self, to: "Variant")

        _ = try variantValue.change(to: ExampleClass())
    }

    @Test func variantGetIf() throws {
        var variantValue = try Variant<Int, String, [Float], ExampleClass>(with: 123)

        #expect(variantValue.getIf(as: Int.self) == 123)

        _ = try variantValue.change(to: "")

        #expect(variantValue.getIf(as: Int.self) == nil)

        let _: String = try variantValue.changeAndReturning(to: [Float(1)])

        #expect(variantValue.getIf(as: [Float].self) == [Float(1)])
    }

    @Test func variantWithMultipleSameType() throws {
        var variantValue = try Variant<Double, Int, String, Int>(with: 1)

        #expect(try variantValue.get(as: Int.self) == 1)

        let _: Int = try variantValue.changeAndReturning(to: "")

        #expect(variantValue.getIf(as: Int.self) == nil)

        let _: String = try variantValue.changeAndReturning(to: 2.9)

        #expect(variantValue.getIf(as: Double.self) == 2.9)
    }

    @Test func invaildVariant() throws {
        #expect(throws: VariantError.argumentTypeNotFound) {
            _ = try Variant<Double, Int, String, Int>(with: Float(102))
        }
    }

    @Test func invalidNumberOfTypes() throws {
        #expect(throws: VariantError.invalidNumberOfTypes) {
            let _: Variant<> = try Variant(with: ())
        }
    }

    @Test func variantWithVoid() throws {
        var variantValue: Variant<Void, Int> = try Variant(with: ())

        #expect(variantValue[as: Void.self] == ())

        try variantValue.changeAndReturning(Void.self, to: 34)

        #expect(variantValue[as: Int.self] == 34)
    }

    @Test func variantSubscript() throws {
        var variantValue = try Variant<Double, Int, String, Int>(with: 1)

        #expect(variantValue[as: Int.self] == 1)
        variantValue[as: Int.self] = 8376
        #expect(variantValue[as: Int.self] == 8376)

        let _: Int = try variantValue.changeAndReturning(to: "Variant")
        #expect(variantValue[as: String.self] == "Variant")
    }

    @Test func variantChange() throws {
        var variantValue = try Variant<Double, Int, String, Int>(with: 1)

        #expect(variantValue[as: Int.self] == 1)
        variantValue[as: Int.self] = 8376
        #expect(variantValue[as: Int.self] == 8376)

        #expect(throws: VariantError.argumentTypeNotFound) {
            let _: Int = try variantValue.changeAndReturning(to: Float(2))
        }

        #expect(throws: VariantError.returnTypeNotFound) {
            let _: Float = try variantValue.changeAndReturning(to: "")
        }

        #expect(throws: VariantError.returnTypeNotFound) {
            let _: Float = try variantValue.changeAndReturning(to: Float(2))
        }

        #expect(throws: VariantError.argumentTypeNotFound) {
            try variantValue.interact(as: Float.self) {
                $0.isLess(than: 1000)
            }
        }
    }
}
