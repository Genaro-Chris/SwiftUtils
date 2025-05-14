public enum VariantError: Swift.Error, CustomStringConvertible {
    case invalidNumberOfTypes
    case returnTypeNotFound
    case argumentTypeNotFound
    case wrongTypeSupplied

    public var description: String {
        switch self {

        case .invalidNumberOfTypes:
            "Variant cannot be instantiated with a paramter pack of less than two types"

        case .returnTypeNotFound:
            "Return type supplied isn't among the variant generic parameter pack types"

        case .argumentTypeNotFound:
            "Argument value's type isn't among the variant generic parameter pack types"

        case .wrongTypeSupplied:
            "Argument metatype isn't the correct type for this variant instance"
        }
    }
}
