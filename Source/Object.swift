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
    private var rawID: hid_t

    var id: hid_t {
        precondition(rawID >= 0, "HDF5 object used after close()")
        return rawID
    }

    public func withUnsafeID<Result>(_ body: (hid_t) throws -> Result) rethrows -> Result {
        try body(id)
    }

    init(id: hid_t) {
        precondition(id >= 0, "Object ID needs to be non-negative")
        rawID = id
    }

    /// A handle still open when the last reference goes is closed here.
    /// A `deinit` runs on whichever thread drops that reference, so here
    /// the close goes through `runSynchronously` to reach the actor's executor;
    /// an object already closed by `close()` is recognised before that and
    /// takes no turn on it.
    deinit {
        let id = rawID
        guard id >= 0 else { return }
        HDF5Actor.runSynchronously { _ = Self.closeHandle(id) }
    }

    /// Closes the handle now instead of leaving it to `deinit`.
    ///
    /// HDF5 keeps a file open for as long as any handle into it is open,
    /// and `deinit` runs when and where the last reference happens to go.
    /// So a caller that needs a file closed closes explicitly.
    /// The object is then no longer usable. Closing twice does nothing.
    /// Throws when HDF5 reports that the close failed, which for a file is
    /// where a failed flush surfaces; the object is unusable either way.
    public func close() throws {
        let id = rawID
        guard id >= 0 else { return }
        rawID = -1
        if Self.closeHandle(id) < 0 { throw HDF5Error.lastError() }
    }

    /// Closes `id` with the call its type needs and returns HDF5's result;
    /// a handle HDF5 no longer knows counts as closed. Runs on the actor's
    /// executor in both of its callers.
    nonisolated private static func closeHandle(_ id: hid_t) -> herr_t {
        guard H5Iis_valid(id) > 0 else { return 0 }
        switch H5Iget_type(id) {
        case H5I_FILE:
            return H5Fclose(id)
        case H5I_GROUP:
            return H5Gclose(id)
        case H5I_DATASET:
            return H5Dclose(id)
        case H5I_DATATYPE:
            return H5Tclose(id)
        default:
            return H5Oclose(id)
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
