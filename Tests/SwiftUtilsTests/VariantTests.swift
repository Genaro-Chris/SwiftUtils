import Foundation
import Testing

@testable import Utilities

@Suite("Variant Tests")
struct VariantTests {
    @Test
    func variant() {
        var variantValue: Variant<ExampleClass, Int, String, [Float]> = Variant(with: "String")

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

        variantValue.interact(as: String.self) { $0 = "Variant in Swift" }

        let oldValue: String = variantValue.get(as: String.self)

        #expect(oldValue == "Variant in Swift")

        _ = variantValue.change(to: 25)

        variantValue.interact(as: Int.self) {
            $0 += 25
            $0 *= 2
        }

        #expect(variantValue.get(as: Int.self) == 100)

        _ = variantValue.change(to: ExampleClass())

    }

    @Test
    func anotherVariant() throws {
        var variantValue = Variant<Int, String, [Float], ExampleClass>(with: 123)

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

        variantValue.interact(as: Int.self) { $0 = 123 }

        #expect(variantValue.get(as: Int.self) == 123)

        _ = variantValue.change(to: 99)

        let oldValue: Int = variantValue.change(to: [Float(253.89)])

        #expect(oldValue == 99)

        variantValue.interact(as: [Float].self) {
            $0[0] += 25
            $0[0] *= 2
        }

        #expect(variantValue.get(as: [Float].self) == [557.78])

        let _: [Float] = variantValue.change(to: "Variant")

        _ = variantValue.change(to: ExampleClass())

    }
}
