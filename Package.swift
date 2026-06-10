// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Vaani",
    platforms: [.iOS("26.0")],
    products: [
        .executable(name: "Vaani", targets: ["VaaniApp"])
    ],
    targets: [
        .executableTarget(
            name: "VaaniApp",
            path: "Vaani"
        )
    ]
)
