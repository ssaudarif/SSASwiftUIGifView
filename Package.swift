// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSASwiftUIGifView",
    platforms: [
            .macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7)
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SSASwiftUIGifView",
            targets: ["SSASwiftUIGifView"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SSASwiftUIGifView",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "myGifViewTests",
            dependencies: ["SSASwiftUIGifView"]),
        .testTarget(
            name: "DemoApp",
            dependencies: ["SSASwiftUIGifView"],
            resources: [
                // Copy Tests/ExampleTests/Resources directories as-is.
                // Use to retain directory structure.
                // Will be at top level in bundle.
                .copy("DemoApp/Gifs"),
              ]),
    ]
)
