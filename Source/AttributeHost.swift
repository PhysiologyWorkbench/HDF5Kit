// Copyright © 2026 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

@HDF5Actor
public protocol AttributeHost {
    /// Provides temporary access to the underlying HDF5 identifier while isolated to `HDF5Actor`.
    ///
    /// The identifier is owned by this wrapper. Do not store or use it after `body` returns.
    func withUnsafeID<Result>(_ body: (hid_t) throws -> Result) rethrows -> Result
}
