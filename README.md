# Swift Utilites

# Overview

Utilities is a Swift library designed to provide more features that I feel that the language lacks. It allows developers to features that are readily available in other languages for example the Variant type this package provides could be likened to the std::variant of c++ language.


# Features

- Variant
- Tuple
- MaybeUninit
- Functions

And many more to be added later such as

- Isolated Functions
- Sendable Functions

# Installation

To use this package

First, add the following package dependency to your `package.swift` file

```swift
.package(url: "https://github.com/Genaro-Chris/SwiftUtils", branch: "main")
```

Then add the `Utilities` library to the target(s) you want to use it

```swift
.product(name: "Utilities", package: "SwiftUtils")
```

# Usage

For example to use the Variant construct

```swift
import Utilities

var variant = try Variant<String, Int, Double>(with: 12)

variant.visit(
    { (intValue: Int) in
        print("Variant as an Int: \(intValue)")
    },
    { (stringValue: String) in
        print("Variant as an String: \(stringValue)")
    },
    { (doubleValue: Double) in
        print("Variant as an Double: \(doubleValue)")
    }
)

try variant.interact(as: Int.self) {
    $0 += 24
}

var oldValue = try variant.change(to: "Variant")
```

Or using the MaybeUninit construct

```swift
var uninit = MaybeUninit<cpptype>() // cpptype is complex type that required further initiailization

uninit.unsafeInitialize { pointer in
    cpptype_init(pointer)
}

// uninit is now fully initialized and can be used without fear of UB (Undefined Behaviour) from improper initialization

let cppResult = uninit.value.cpp_method(123)

// This method of zeroInitalized is similar to c initialization technique
// ctype_t val = ctype_t{0};
var anotherUninit = MaybeUninit<ctype_t>.zeroInitialize() // ctype_t is simple type that can zero initiailized

let cResult = ctype_method(&anotherUninit, 93)
```

## Contributing

I highly welcome and encourage all sorts of contributions from all swift developers. Feel free to star the repository

If you like this project you can contribute it by:

- Submit a bug report by opening an [issue](https://github.com/Genaro-Chris/SwiftUtils/issues)
- Submit code by opening a [pull request](https://github.com/Genaro-Chris/SwiftUtils/pulls)

## Hire

I'm available for hire whether full time or part-time at the moment. Reach out to me at [this email](mailto:christian25589@gmail.com)

## License
This package is released under Apache-2.0 license. See [LICENSE](LICENSE.txt) for more information.
