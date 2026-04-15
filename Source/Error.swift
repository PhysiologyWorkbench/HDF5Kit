// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

public enum HDF5Error: Swift.Error {
    case ioError(description: String)

    /// Captures that an HDF5 error occurred.
    /// In a more advanced implementation, this would walk the H5E error stack.
    static func lastError() -> HDF5Error {
        // HDF5 usually prints errors to stderr by default.
        return .ioError(description: "HDF5 error(s) occurred. See stderr for details.")
    }
}

// Keep the old Error name for compatibility.
public typealias Error = HDF5Error
