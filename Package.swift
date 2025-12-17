// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "mParticle-Mixpanel",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .macOS(.v10_13),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "mParticle-Mixpanel",
            targets: ["mParticle-Mixpanel"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/mParticle/mparticle-apple-sdk",
            .upToNextMajor(from: "8.0.0")
        ),
        .package(
            url: "https://github.com/mixpanel/mixpanel-swift",
            .upToNextMajor(from: "4.0.0")
        ),
    ],
    targets: [
        .target(
            name: "mParticle-Mixpanel",
            dependencies: [
                .product(name: "mParticle-Apple-SDK", package: "mparticle-apple-sdk"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
            ],
            path: "Sources/mParticle-Mixpanel"
        ),
        .testTarget(
            name: "mParticle-MixpanelTests",
            dependencies: ["mParticle-Mixpanel"],
            path: "Tests/mParticle-MixpanelTests"
        ),
    ]
)
