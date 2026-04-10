// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HomePodControl",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "HomePodControl",
            path: "Sources"
        )
    ]
)
