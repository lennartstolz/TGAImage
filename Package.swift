// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TGAImage",
    products: [
        .library(
            name: "TGAImage",
            targets: ["TGAImage"]),
    ],
    targets: [
        .target(
            name: "TGAImage",
            dependencies: []),
        .testTarget(
            name: "TGAImageTests",
            dependencies: ["TGAImage"],
            resources: [
                .copy("Resources")
            ])
    ]
)
