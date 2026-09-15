// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Reminderly",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "Reminderly", targets: ["Reminderly"])],
    targets: [.executableTarget(name: "Reminderly", path: "Sources")]
)
