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
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "FreetifyCore",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "."
        ),
        .testTarget(
            name: "FreetifyTests",
            dependencies: ["FreetifyCore"],
            path: "Tests"
        )
    ]
)
