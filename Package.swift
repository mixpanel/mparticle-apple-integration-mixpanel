// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "mParticle-Mixpanel",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "mParticle-Mixpanel",
            targets: ["mParticle-Mixpanel", "mParticle-MixpanelObjC"]
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
        // Main Swift implementation
        .target(
            name: "mParticle-Mixpanel",
            dependencies: [
                .product(name: "mParticle-Apple-SDK", package: "mparticle-apple-sdk"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
            ],
            path: "Sources/mParticle-Mixpanel"
        ),
        // ObjC target for automatic kit registration via +load
        .target(
            name: "mParticle-MixpanelObjC",
            dependencies: [
                "mParticle-Mixpanel",
                .product(name: "mParticle-Apple-SDK", package: "mparticle-apple-sdk"),
            ],
            path: "Sources/mParticle-MixpanelObjC",
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "mParticle-MixpanelTests",
            dependencies: ["mParticle-Mixpanel"],
            path: "Tests/mParticle-MixpanelTests"
        ),
    ]
)
