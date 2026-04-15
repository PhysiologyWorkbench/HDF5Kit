// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

public typealias DoubleDataset = TypedDataset<Double>

extension GroupType {
    public func createDoubleDataset(_ name: String, dataspace: Dataspace) -> DoubleDataset? {
        return createDataset(name, dataspace: dataspace)
    }

    public func createDoubleDataset(_ name: String, dataspace: Dataspace, chunkDimensions: [Int]) -> DoubleDataset? {
        return createDataset(name, dataspace: dataspace, chunkDimensions: chunkDimensions)
    }

    public func openDoubleDataset(_ name: String) -> DoubleDataset? {
        return openDataset(name)
    }
}
