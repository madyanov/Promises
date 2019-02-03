// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Promises",
    products: [
        .library(
            name: "Promises",
            targets: ["Promises"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Promises",
            dependencies: []
        ),
        .testTarget(
            name: "PromisesTests",
            dependencies: ["Promises"]
        ),
    ]
)
