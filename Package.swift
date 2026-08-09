// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ZodiacDailyCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ZodiacDailyCore",
            targets: ["ZodiacDailyCore"]
        )
    ],
    targets: [
        .target(
            name: "ZodiacDailyCore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ZodiacDailyCoreTests",
            dependencies: ["ZodiacDailyCore"]
        )
    ]
)
