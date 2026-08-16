// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Freetify",
    defaultLocalization: "id",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FreetifyCore",
            targets: ["FreetifyCore"]
        ),
    ],
    targets: [
        .target(
            name: "FreetifyCore",
            path: "."
        ),
        .testTarget(
            name: "FreetifyTests",
            dependencies: ["FreetifyCore"],
            path: "Tests"
        )
    ]
)
