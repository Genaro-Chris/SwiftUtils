// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUtils",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Utilities",
            targets: ["Utilities"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Utilities",
            swiftSettings: [
                .enableExperimentalFeature("BuiltinModule"),
                .enableExperimentalFeature("RawLayout"),
                .enableExperimentalFeature("NoncopyableGenerics"),
                .enableExperimentalFeature("NoncopyableGenerics2"),
                .enableExperimentalFeature("BitwiseCopyable"),
                .enableExperimentalFeature("BitwiseCopyable2"),
                .enableExperimentalFeature("SuppressedAssociatedTypes"),
                .enableExperimentalFeature("BuiltinAddressOfRawLayout"),
                .enableExperimentalFeature("BuiltinStoreRaw"),
                .enableExperimentalFeature("NoncopyableGenerics2"),
                .unsafeFlags([
                    "-enable-builtin-module"
                ]),
            ]),
        .testTarget(
            name: "SwiftUtilsTests",
            dependencies: ["Utilities"]
        ),
    ]
)
