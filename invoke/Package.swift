// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "invoke",
    platforms: [
        .macOS(.v10_14),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/JohnSundell/Files.git", from: "4.1.1"),
        .package(url: "https://github.com/kareman/Moderator.git", from: "0.5.1"),
        .package(url: "https://github.com/DanielCech/ScriptToolkit.git", .branch("master")),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.0.1"),
        .package(url: "https://github.com/kareman/FileSmith.git", from: "0.3.0"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "invoke",
            dependencies: ["Files", "FileSmith", "SwiftShell", "ScriptToolkit", "Moderator", "Stencil"]
        ),
        .testTarget(
            name: "invokeTests",
            dependencies: ["invoke"]
        ),
    ]
)
