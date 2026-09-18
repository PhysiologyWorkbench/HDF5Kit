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

extension AttributeHost {
    /// The names of this object's attributes.
    ///
    /// The counterpart of `Group.objectNames()`, and the only way to read a
    /// group whose attribute *names* are themselves data — a set of named
    /// parameters, say, whose names the reader cannot know in advance.
    public func attributeNames() -> [String] {
        withUnsafeID { objectID in
            let count = H5Aget_num_attrs(objectID)
            guard count > 0 else { return [] }
            return (0..<count).compactMap { index in
                let size = H5Aget_name_by_idx(
                    objectID, ".", H5_INDEX_NAME, H5_ITER_INC, hsize_t(index), nil, 0, 0)
                guard size > 0 else { return nil }
                var name = [CChar](repeating: 0, count: size + 1)
                H5Aget_name_by_idx(
                    objectID, ".", H5_INDEX_NAME, H5_ITER_INC, hsize_t(index),
                    &name, size + 1, 0)
                return String(utf8String: name)
            }
        }
    }
}
