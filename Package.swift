// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CatIt",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "CatIt", targets: ["CatIt"])
    ],
    targets: [
        .target(name: "CatIt", path: "CatIt/Sources"),
        .testTarget(name: "CatItTests", dependencies: ["CatIt"], path: "CatItTests")
    ]
)
