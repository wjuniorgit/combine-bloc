// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineBloc",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "CombineBloc",
            targets: ["CombineBloc"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CombineBloc",
            dependencies: []),
        .testTarget(
            name: "CombineBlocTests",
            dependencies: ["CombineBloc"]),
    ]
)
