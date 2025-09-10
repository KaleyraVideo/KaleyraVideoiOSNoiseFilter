// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KaleyraVideoNoiseFilter",
    platforms: [ .iOS(.v15) ],
    products: [
        .library(name: "KaleyraVideoNoiseFilter", targets: ["KaleyraVideoNoiseFilter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/KaleyraVideo/iOSDeepFilterNet.git", .upToNextMinor(from: "0.0.39")),
        .package(url: "https://github.com/nschum/SwiftHamcrest.git", from: "2.2.4"),
        .package(url: "https://github.com/KaleyraVideo/KaleyraTestKit.git", branch: "master")
    ],
    targets: [
        .target(
            name: "KaleyraVideoNoiseFilter",
            dependencies: [
                .product(name: "DeepFilterNet", package: "iOSDeepFilterNet"),
            ],
            path: "Core/KaleyraVideoNoiseFilter",
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "KaleyraVideoNoiseFilterTests",
            dependencies: [
                .target(name: "KaleyraVideoNoiseFilter"),
                .product(name: "SwiftHamcrest", package: "SwiftHamcrest"),
                .product(name: "KaleyraTestKit", package: "KaleyraTestKit"),
                .product(name: "KaleyraTestMatchers", package: "KaleyraTestKit"),
                .product(name: "KaleyraTestHelpers", package: "KaleyraTestKit"),
            ],
            path: "Core/KaleyraVideoNoiseFilterTests",
            resources: [
                .process("TestResources")
            ]
        ),
    ]
)
