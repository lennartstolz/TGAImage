// swift-tools-version:5.3
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
                .copy("Resources/white-reference-image.tga"),
                .copy("Resources/black-reference-image.tga"),
                .copy("Resources/rgb-reference-image.tga"),
                .copy("Resources/gradient-reference-image.tga"),
                .copy("Resources/red-bottom-left-reference-image.tga"),
                .copy("Resources/red-bottom-right-reference-image.tga"),
                .copy("Resources/red-top-left-reference-image.tga"),
                .copy("Resources/red-top-right-reference-image.tga")
            ])
    ]
)
