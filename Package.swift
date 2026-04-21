// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "HDF5Kit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "HDF5Kit",
            targets: ["HDF5Kit"]),
    ],
    targets: [
        .target(
            name: "CHDF5",
            path: "Source/CHDF5",
            sources: ["empty.c"],
            publicHeadersPath: "include"),
        .target(
            name: "HDF5Kit",
            dependencies: ["CHDF5"],
            path: "Source",
            exclude: ["CHDF5", "HDF5Kit.h"],
            linkerSettings: [
                .unsafeFlags([
                    "/opt/homebrew/opt/hdf5/lib/libhdf5.a",
                    "/opt/homebrew/lib/libsz.a",
                    "/opt/homebrew/lib/libaec.a",
                    "-lz", "-lm"
                ])
            ]),
        .testTarget(
            name: "HDF5KitTests",
            dependencies: ["HDF5Kit"]),
    ]
)
