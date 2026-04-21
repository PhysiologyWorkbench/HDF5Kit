// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

/// A generic HDF5 Attribute.
@HDF5Actor
open class TypedAttribute<T: HDF5Representable>: Attribute {
    open func read() throws -> [T] {
        let count = space.size
        let data = UnsafeMutablePointer<T>.allocate(capacity: count)
        defer { data.deallocate() }
        
        try read(into: data, type: T.hdf5Type)
        return Array(UnsafeBufferPointer(start: data, count: count))
    }

    open func write(_ data: [T]) throws {
        try data.withUnsafeBufferPointer { pointer in
            try write(from: pointer.baseAddress!, type: T.hdf5Type)
        }
    }
}

// MARK: AttributeHost extension for TypedAttribute

extension AttributeHost {
    public func createAttribute<T: HDF5Representable>(_ name: String, dataspace: Dataspace) -> TypedAttribute<T>? {
        if T.self == String.self {
            return createStringAttribute(name) as? TypedAttribute<T>
        }
        let attributeID = withUnsafeID { objectID in
            name.withCString { name in
                H5Acreate2(objectID, name, T.hdf5Type.rawValue, dataspace.id, 0, 0)
            }
        }
        guard attributeID >= 0 else { return nil }
        return TypedAttribute<T>(id: attributeID)
    }

    public func openAttribute<T: HDF5Representable>(_ name: String) -> TypedAttribute<T>? {
        if T.self == String.self {
            return openStringAttribute(name) as? TypedAttribute<T>
        }
        let attributeID = withUnsafeID { objectID in
            name.withCString { name in
                H5Aopen(objectID, name, 0)
            }
        }
        guard attributeID >= 0 else {
            return nil
        }
        return TypedAttribute<T>(id: attributeID)
    }
}
