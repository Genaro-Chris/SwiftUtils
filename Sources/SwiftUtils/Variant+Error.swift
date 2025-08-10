/// Error thrown while using the `Variant` construct
@frozen
public enum VariantError: Swift.Error, CustomStringConvertible {
    case argumentTypeNotFound
    case invalidNumberOfTypes
    case returnTypeNotFound
    case wrongTypeSupplied

    public var description: String {
        switch self {

        case .invalidNumberOfTypes:
            "Variant cannot be instantiated with a paramter pack of less than two types"

        case .returnTypeNotFound:
            "Return type supplied is not among the variant generic parameter pack types"

        case .argumentTypeNotFound:
            "Argument metatype is not among the variant generic parameter pack types"

        case .wrongTypeSupplied:
            "Argument's value type is not the correct type for this variant instance"
        }
    }
}
