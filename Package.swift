// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickBloxUIKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "QuickBloxUIKit",
            targets: ["QuickBloxUIKit", "QuickBloxData", "QuickBloxDomain"]),
    ],
    dependencies: [
        .package(url: "https://github.com/QuickBlox/ios-quickblox-sdk", .upToNextMajor(from: "2.19.0")),
        .package(url: "https://github.com/QuickBlox/ios-ai-answer-assistant.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/QuickBlox/ios-ai-translate.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/QuickBlox/ios-ai-rephrase.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "QuickBloxUIKit",
            dependencies: ["QuickBloxData",
                           "QuickBloxLog"],
            resources: [.process("Resources")]),
        .target(
            name: "QuickBloxData",
            dependencies: ["QuickBloxDomain",
                           "QuickBloxLog"]),
        .target(
            name: "QuickBloxDomain",
            dependencies: ["QuickBloxLog",
                           .product(name: "Quickblox",
                                    package: "ios-quickblox-sdk"),
                           .product(name: "QBAIAnswerAssistant",
                                    package: "ios-ai-answer-assistant"),
                           .product(name: "QBAITranslate",
                                    package: "ios-ai-translate"),
                           .product(name: "QBAIRephrase",
                                    package: "ios-ai-rephrase")]),
        .target(
            name: "QuickBloxLog",
            dependencies: []),
        .testTarget(
            name: "QuickBloxUIKitTests",
            dependencies: ["QuickBloxUIKit",
                           "QuickBloxData",
                           "QuickBloxLog"],
            resources: [.process("Resources")]),
    ]
)
