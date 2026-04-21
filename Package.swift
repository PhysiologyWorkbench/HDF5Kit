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
            path: ".",
            exclude: [
                "dist/src/CMakeLists.txt",
                "dist/src/COPYING",
                "dist/src/H5config.h.in",
                "dist/src/H5detect.c",
                "dist/src/H5err.txt",
                "dist/src/H5make_libsettings.c",
                "dist/src/H5overflow.txt",
                "dist/src/H5vers.txt",
                "dist/src/Makefile.am",
                "dist/src/Makefile.in",
                "dist/src/libhdf5.settings.in",
            ],
            sources: [
                "Source/CHDF5/empty.c",
                "dist/src",
            ],
            publicHeadersPath: "Source/CHDF5/include",
            cSettings: [
                .headerSearchPath("dist/src"),
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("m"),
            ]),
        .target(
            name: "HDF5Kit",
            dependencies: ["CHDF5"],
            path: "Source",
            exclude: ["CHDF5", "HDF5Kit.h"]),
        .testTarget(
            name: "HDF5KitTests",
            dependencies: ["HDF5Kit"]),
    ]
)
