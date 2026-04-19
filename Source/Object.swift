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
    nonisolated(unsafe) public internal(set) var id: hid_t = -1

    public init(id: hid_t) {
        precondition(id >= 0, "Object ID needs to be non-negative")
        self.id = id
    }

    deinit {
        HDF5Actor.runSynchronously {
            guard id >= 0 && H5Iis_valid(id) > 0 else { return }
            let type = H5Iget_type(id)
            switch type {
            case H5I_FILE:
                H5Fclose(id)
            case H5I_GROUP:
                H5Gclose(id)
            case H5I_DATASET:
                H5Dclose(id)
            case H5I_DATATYPE:
                H5Tclose(id)
            default:
                H5Oclose(id)
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

public func == (lhs: Object, rhs: Object) -> Bool {
    return lhs.id == rhs.id
}
