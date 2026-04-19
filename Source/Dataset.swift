// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

@HDF5Actor
open class Dataset: Object, AttributeHost {
    public var offset: Int? {
        let offset = H5Dget_offset(id)
        guard offset != UInt64(bitPattern: Int64(-1)) else {
            return nil
        }
        return Int(offset)
    }

    public var space: Dataspace {
        return Dataspace(id: H5Dget_space(id))
    }

    public var type: Datatype {
        return Datatype(id: H5Dget_type(id))
    }

    public var extent: [Int] {
        get {
            return space.dims
        }
        set {
            let dims64 = newValue.map({ hsize_t(bitPattern: hssize_t($0)) })
            _ = dims64.withUnsafeBufferPointer { pointer in
                H5Dset_extent(id, pointer.baseAddress)
            }
        }
    }

    open func read(into pointer: UnsafeMutableRawPointer, type: NativeType, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        let status = H5Dread(id, type.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, pointer)
        if status < 0 {
            throw HDF5Error.lastError()
        }
    }

    open func write(from pointer: UnsafeRawPointer, type: NativeType, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        let status = H5Dwrite(id, type.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, pointer);
        if status < 0 {
            throw HDF5Error.lastError()
        }
    }
}
