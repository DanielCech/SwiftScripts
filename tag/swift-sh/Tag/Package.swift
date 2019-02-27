// swift-tools-version:4.2
import PackageDescription

let package = Package(name: "Tag")

package.products = [
    .executable(name: "Tag", targets: ["Tag"])
]
package.dependencies = [
    .package(url: "https://github.com/DanielCech/Files.git", .upToNextMajor(from: Version(2,2,0))),
    .package(url: "https://github.com/kareman/SwiftShell.git", .upToNextMajor(from: Version(4,1,0))),
    .package(url: "https://github.com/DanielCech/Moderator.git", .upToNextMajor(from: Version(0,5,0))),
    .package(url: "https://github.com/DanielCech/ScriptToolkit.git", .upToNextMajor(from: Version(0,1,0)))
]
package.targets = [
    .target(name: "Tag", dependencies: ["Files", "SwiftShell", "Moderator", "ScriptToolkit"], path: "Sources")
]
