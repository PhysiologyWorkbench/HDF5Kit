// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

public typealias FloatDataset = TypedDataset<Float>

extension GroupType {
    public func createFloatDataset(_ name: String, dataspace: Dataspace, compression: Int? = nil) -> FloatDataset? {
        return createDataset(name, dataspace: dataspace, compression: compression)
    }

    public func createFloatDataset(_ name: String, dataspace: Dataspace, chunkDimensions: [Int], compression: Int? = nil) -> FloatDataset? {
        return createDataset(name, dataspace: dataspace, chunkDimensions: chunkDimensions, compression: compression)
    }

    public func openFloatDataset(_ name: String) -> FloatDataset? {
        return openDataset(name)
    }
}
