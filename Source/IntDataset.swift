// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

public typealias IntDataset = TypedDataset<Int>

extension GroupType {
    public func createIntDataset(_ name: String, dataspace: Dataspace) -> IntDataset? {
        return createDataset(name, dataspace: dataspace)
    }

    public func createIntDataset(_ name: String, dataspace: Dataspace, chunkDimensions: [Int]) -> IntDataset? {
        return createDataset(name, dataspace: dataspace, chunkDimensions: chunkDimensions)
    }

    public func openIntDataset(_ name: String) -> IntDataset? {
        return openDataset(name)
    }
}
