// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

@HDF5Actor
open class Object {
    private let rawID: hid_t

    var id: hid_t {
        rawID
    }

    public func withUnsafeID<Result>(_ body: (hid_t) throws -> Result) rethrows -> Result {
        try body(rawID)
    }

    init(id: hid_t) {
        precondition(id >= 0, "Object ID needs to be non-negative")
        rawID = id
    }

    deinit {
        HDF5Actor.runSynchronously {
            guard rawID >= 0 && H5Iis_valid(rawID) > 0 else { return }
            let type = H5Iget_type(rawID)
            switch type {
            case H5I_FILE:
                H5Fclose(rawID)
            case H5I_GROUP:
                H5Gclose(rawID)
            case H5I_DATASET:
                H5Dclose(rawID)
            case H5I_DATATYPE:
                H5Tclose(rawID)
            default:
                H5Oclose(rawID)
            }
        }
    }

    public var file: File {
        let fileID = H5Iget_file_id(id)
        return File(id: fileID)
    }

    open var name: String {
        let count = H5Iget_name(id, nil, 0)
        if count <= 0 {
            return ""
        }

        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: count + 1)
        defer { pointer.deallocate() }
        H5Iget_name(id, pointer, count + 1)
        return String(utf8String: pointer)!
    }
}

@HDF5Actor
public func == (lhs: Object, rhs: Object) -> Bool {
    return lhs.id == rhs.id
}
