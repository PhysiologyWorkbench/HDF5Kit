// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

/// A generic HDF5 Dataset.
@HDF5Actor
open class TypedDataset<T: HDF5Representable>: Dataset {
    public subscript(slices: HyperslabIndexType...) -> [T] {
        get {
            return (try? read(slices)) ?? []
        }
        set {
            try! write(newValue, to: slices)
        }
    }

    public subscript(slices: [HyperslabIndexType]) -> [T] {
        get {
            return (try? read(slices)) ?? []
        }
        set {
            try! write(newValue, to: slices)
        }
    }

    open func read(_ slices: [HyperslabIndexType]) throws -> [T] {
        let filespace = space
        filespace.select(slices)
        let memspace = Dataspace(dims: [filespace.selectionSize])
        return try read(memSpace: memspace, fileSpace: filespace)
    }

    open func write(_ data: [T], to slices: [HyperslabIndexType]) throws {
        let filespace = space
        filespace.select(slices)
        let memspace = Dataspace(dims: [filespace.selectionSize])
        try write(data, memSpace: memspace, fileSpace: filespace)
    }

    open func read(memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws -> [T] {
        let count: Int
        if let memSpace = memSpace {
            count = memSpace.selectionSize
        } else if let fileSpace = fileSpace {
            count = fileSpace.selectionSize
        } else {
            count = space.selectionSize
        }

        let data = UnsafeMutablePointer<T>.allocate(capacity: count)
        defer { data.deallocate() }

        try read(into: data, type: T.hdf5Type, memSpace: memSpace, fileSpace: fileSpace)
        return Array(UnsafeBufferPointer(start: data, count: count))
    }

    open func write(_ data: [T], memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        try data.withUnsafeBufferPointer { pointer in
            try write(from: pointer.baseAddress!, type: T.hdf5Type, memSpace: memSpace, fileSpace: fileSpace)
        }
    }

    /// Append data to the table
    public func append(_ data: [T], dimensions: [Int], axis: Int = 0) throws {
        let oldExtent = extent
        var newExtent = oldExtent
        newExtent[axis] += dimensions[axis]
        for (index, dim) in dimensions.enumerated() {
            if dim > newExtent[index] {
                newExtent[index] = dim
            }
        }
        extent = newExtent

        var start = [Int](repeating: 0, count: oldExtent.count)
        start[axis] = oldExtent[axis]

        let fileSpace = space
        fileSpace.select(start: start, stride: nil, count: dimensions, block: nil)

        try write(data, memSpace: Dataspace(dims: dimensions), fileSpace: fileSpace)
    }
}

extension GroupType {
    /// Create a TypedDataset
    public func createDataset<T: HDF5Representable>(_ name: String, dataspace: Dataspace) -> TypedDataset<T>? {
        if T.self == String.self {
            return createStringDataset(name, dataspace: dataspace) as? TypedDataset<T>
        }
        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, T.hdf5Type.rawValue, dataspace.id, 0, 0, 0)
        }
        guard datasetID >= 0 else { return nil }
        return TypedDataset<T>(id: datasetID)
    }

    /// Create a chunked TypedDataset
    public func createDataset<T: HDF5Representable>(_ name: String, dataspace: Dataspace, chunkDimensions: [Int]) -> TypedDataset<T>? {
        if T.self == String.self {
            return createStringDataset(name, dataspace: dataspace, chunkDimensions: chunkDimensions) as? TypedDataset<T>
        }
        precondition(dataspace.dims.count == chunkDimensions.count)

        let plist = H5Pcreate(H5P_CLS_DATASET_CREATE_ID_g)
        H5Pset_char_encoding(plist, H5T_CSET_UTF8)
        let chunkDimensions64 = chunkDimensions.map({ hsize_t(bitPattern: hssize_t($0)) })
        chunkDimensions64.withUnsafeBufferPointer { (pointer) -> Void in
            H5Pset_chunk(plist, Int32(chunkDimensions.count), pointer.baseAddress)
        }
        defer {
            H5Pclose(plist)
        }

        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, T.hdf5Type.rawValue, dataspace.id, 0, plist, 0)
        }
        guard datasetID >= 0 else { return nil }
        return TypedDataset<T>(id: datasetID)
    }

    /// Create a TypedDataset and write data
    public func createAndWriteDataset<T: HDF5Representable>(_ name: String, dims: [Int], data: [T]) throws -> TypedDataset<T> {
        let space = Dataspace(dims: dims)
        guard let set: TypedDataset<T> = createDataset(name, dataspace: space) else {
            throw Error.lastError()
        }
        try set.write(data)
        return set
    }

    /// Open an existing TypedDataset
    public func openDataset<T: HDF5Representable>(_ name: String) -> TypedDataset<T>? {
        if T.self == String.self {
            return openStringDataset(name) as? TypedDataset<T>
        }
        let datasetID = name.withCString{ name in
            return H5Dopen2(id, name, 0)
        }
        guard datasetID >= 0 else {
            return nil
        }
        return TypedDataset<T>(id: datasetID)
    }
}
