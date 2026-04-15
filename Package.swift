// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "HDF5Kit",
    products: [
        .library(
            name: "HDF5Kit",
            targets: ["HDF5Kit"]),
    ],
    targets: [
        .systemLibrary(
            name: "CHDF5",
            path: "Source/CHDF5",
            pkgConfig: "hdf5",
            providers: [
                .brew(["hdf5"]),
                .apt(["libhdf5-dev"])
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
