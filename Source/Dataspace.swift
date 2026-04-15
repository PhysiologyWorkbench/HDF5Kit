// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

@HDF5Actor
public class Dataspace {
    nonisolated(unsafe) var id: hid_t

    init(id: hid_t) {
        self.id = id
        guard id >= 0 else {
            fatalError("Failed to create Dataspace")
        }
        selectionDims = []
        selectionDims = dims
    }

    deinit {
        if id >= 0 && H5Iis_valid(id) > 0 {
            H5Sclose(id)
        }
    }

    public func copy() -> Dataspace {
        return Dataspace(id: H5Scopy(id))
    }

    public internal(set) var selectionDims: [Int]

    /// Create a Dataspace
    public init(dims: [Int], maxDims: [Int]? = nil) {
        let dims64 = dims.map({ hsize_t(bitPattern: hssize_t($0)) })
        let maxDims64 = maxDims?.map({ $0 < 0 ? UInt64(bitPattern: Int64(-1)) : hsize_t(bitPattern: hssize_t($0)) })
        
        id = dims64.withUnsafeBufferPointer { (dimsPointer) in
            if let maxDims64 = maxDims64 {
                return maxDims64.withUnsafeBufferPointer { (maxDimsPointer) in
                    return H5Screate_simple(Int32(dims.count), dimsPointer.baseAddress, maxDimsPointer.baseAddress)
                }
            }
            return H5Screate_simple(Int32(dims.count), dimsPointer.baseAddress, nil)
        }
        selectionDims = dims
    }

    /// The number of elements in the Dataspace
    public var size: Int {
        return Int(H5Sget_simple_extent_npoints(id))
    }

    /// The number of dimensions in the Dataspace
    public var ndims: Int {
        return Int(H5Sget_simple_extent_ndims(id))
    }

    /// The dimension extents
    public var dims: [Int] {
        let rank = ndims
        var dims = [hsize_t](repeating: 0, count: rank)
        H5Sget_simple_extent_dims(id, &dims, nil)
        return dims.map({ Int(hssize_t(bitPattern: $0)) })
    }

    /// The maximum dimension extents
    public var maxDims: [Int] {
        let rank = ndims
        var maxDims = [hsize_t](repeating: 0, count: rank)
        H5Sget_simple_extent_dims(id, nil, &maxDims)
        return maxDims.map({ $0 == UInt64(bitPattern: Int64(-1)) ? -1 : Int(hssize_t(bitPattern: $0)) })
    }

    public var selectionSize: Int {
        return Int(H5Sget_select_npoints(id))
    }

    /// Selects the entire dataspace.
    public func selectAll() {
        H5Sselect_all(id)
        selectionDims = dims
    }

    /// Resets the selection region to include no elements.
    public func selectNone() {
        H5Sselect_none(id)
        for i in 0..<selectionDims.count {
            selectionDims[i] = 0
        }
    }

    /// Select a hyperslab region.
    ///
    /// - parameter start:  Specifies the offset of the starting element of the specified hyperslab.
    /// - parameter stride: Chooses array locations from the dataspace with each value in the stride array determining how many elements to move in each dimension. Stride values of 0 are not allowed. If the stride parameter is `nil`, a contiguous hyperslab is selected (as if each value in the stride array were set to 1).
    /// - parameter count:  Determines how many blocks to select from the dataspace, in each dimension.
    /// - parameter block:  Determines the size of the element block selected from the dataspace. If the block parameter is set to `nil`, the block size defaults to a single element in each dimension (as if each value in the block array were set to 1).
    public func select(start: [Int], stride: [Int]?, count: [Int]?, block: [Int]?) {
        let start64 = start.map({ hsize_t(bitPattern: hssize_t($0)) })
        let stride64 = stride?.map({ hsize_t(bitPattern: hssize_t($0)) })
        let count64 = count?.map({ hsize_t(bitPattern: hssize_t($0)) })
        let block64 = block?.map({ hsize_t(bitPattern: hssize_t($0)) })

        start64.withUnsafeBufferPointer { startPointer in
            withOptionalUnsafeBufferPointer(stride64) { stridePointer in
                withOptionalUnsafeBufferPointer(count64) { countPointer in
                    withOptionalUnsafeBufferPointer(block64) { blockPointer in
                        H5Sselect_hyperslab(id, H5S_SELECT_SET, startPointer.baseAddress, stridePointer, countPointer, blockPointer)
                    }
                }
            }
        }
        
        let actualCount = count ?? [Int](repeating: 1, count: start.count)
        let actualBlock = block ?? [Int](repeating: 1, count: start.count)
        var selectionDims = [Int](repeating: 0, count: start.count)
        for i in 0..<start.count {
            selectionDims[i] = actualCount[i] * actualBlock[i]
        }
        self.selectionDims = selectionDims
    }

    /// Select a hyperslab region.
    public func select(_ slices: HyperslabIndexType...) {
        select(slices)
    }

    /// Select a hyperslab region.
    public func select(_ slices: [HyperslabIndexType]) {
        let dims = self.dims
        let rank = dims.count
        var start = [Int](repeating: 0, count: rank)
        var stride = [Int](repeating: 1, count: rank)
        var count = [Int](repeating: 1, count: rank)
        var block = [Int](repeating: 1, count: rank)

        for (index, slice) in slices.enumerated() {
            if index >= rank { break }
            start[index] = slice.start
            stride[index] = slice.stride
            if slice.blockCount != HyperslabIndex.all {
                count[index] = slice.blockCount
            } else {
                let remaining = dims[index] - slice.start
                count[index] = remaining / slice.stride
            }
            block[index] = slice.blockSize
        }

        select(start: start, stride: stride, count: count, block: block)
    }

    /// This function allows the same shaped selection to be moved to different locations within a dataspace without requiring it to be redefined.
    public func offset(_ offset: [Int]) {
        let offset64 = offset.map({ hssize_t($0) })
        offset64.withUnsafeBufferPointer { (pointer) -> Void in
            H5Soffset_simple(id, pointer.baseAddress)
        }
    }
}

func withOptionalUnsafeBufferPointer<T, Result>(_ array: [T]?, _ body: (UnsafePointer<T>?) throws -> Result) rethrows -> Result {
    if let array = array {
        return try array.withUnsafeBufferPointer { try body($0.baseAddress) }
    } else {
        return try body(nil)
    }
}
