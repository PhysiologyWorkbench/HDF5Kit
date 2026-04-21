// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

@testable import HDF5Kit
import Foundation
import Testing

@HDF5Actor
func tempFilePath() -> String {
    let fileName = ProcessInfo.processInfo.globallyUniqueString + ".hdf"
    return NSTemporaryDirectory() + "/" + fileName
}

@HDF5Actor
func createFile(_ filePath: String) -> File {
    guard let file = File.create(filePath, mode: .truncate) else {
        fatalError("Failed to create file")
    }
    return file
}

@HDF5Actor
func openFile(_ filePath: String) -> File {
    guard let file = File.open(filePath, mode: .readOnly) else {
        fatalError("Failed to open file")
    }
    return file
}

@HDF5Actor
func expectHDF5Errors<T>(
    containing expectedMessages: [String],
    during body: () throws -> T
) throws -> T {
    let (result, messages) = HDF5Error.captureAutomaticErrorMessages(during: body)

    #expect(!messages.isEmpty, "Expected HDF5 to emit at least one diagnostic")
    for expectedMessage in expectedMessages {
        #expect(
            messages.contains { $0.localizedCaseInsensitiveContains(expectedMessage) },
            "Expected HDF5 diagnostic containing '\(expectedMessage)', got: \(messages.joined(separator: " | "))"
        )
    }

    return try result.get()
}

@HDF5Actor
func expectNoHDF5Errors<T>(during body: () throws -> T) throws -> T {
    let (result, messages) = HDF5Error.captureAutomaticErrorMessages(during: body)

    #expect(
        messages.isEmpty,
        "Expected no HDF5 diagnostics, got: \(messages.joined(separator: " | "))"
    )

    return try result.get()
}
