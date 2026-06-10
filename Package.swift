// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Vaani",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Vaani", targets: ["VaaniApp"])
    ],
    targets: [
        .executableTarget(
            name: "VaaniApp",
            path: "Sources/VaaniApp"
        )
    ]
)
