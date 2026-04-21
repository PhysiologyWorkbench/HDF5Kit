// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

@HDF5Actor
open class Attribute {
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
            if rawID >= 0 && H5Iis_valid(rawID) > 0 {
                H5Aclose(rawID)
            }
        }
    }

    open var name: String {
        let count = H5Aget_name(id, 0, nil)
        if count <= 0 {
            return ""
        }

        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: count + 1)
        defer { pointer.deallocate() }
        H5Aget_name(id, count + 1, pointer)
        return String(utf8String: pointer)!
    }

    public var space: Dataspace {
        return Dataspace(id: H5Aget_space(id))
    }

    public var type: Datatype {
        return Datatype(id: H5Aget_type(id))
    }

    /// Reads attribute data into a raw pointer.
    open func read(into pointer: UnsafeMutableRawPointer, type: NativeType) throws {
        let status = H5Aread(id, type.rawValue, pointer)
        if status < 0 {
            throw HDF5Error.lastError()
        }
    }

    /// Writes attribute data from a raw pointer.
    open func write(from pointer: UnsafeRawPointer, type: NativeType) throws {
        let status = H5Awrite(id, type.rawValue, pointer);
        if status < 0 {
            throw HDF5Error.lastError()
        }
    }
}
