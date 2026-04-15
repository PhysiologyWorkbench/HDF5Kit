// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
import HDF5Kit

@HDF5Actor
struct DataspaceTests {

    @Test func dimensions() async {
        let height = 10
        let width = 4
        let dataspace = await Dataspace(dims: [height, width], maxDims: [-1, -1])
        let dims = await dataspace.dims
        #expect(dims.count == 2)
        #expect(dims[0] == height)
        #expect(dims[1] == width)
    }

    @Test func maxDimensions() async {
        let height = 10
        let width = 4
        let dataspace = await Dataspace(dims: [height, width], maxDims: [-1, -1])
        let maxDims = await dataspace.maxDims
        #expect(maxDims.count == 2)
        #expect(maxDims[0] == -1)
        #expect(maxDims[1] == -1)
    }

    @Test func select() async {
        let height = 10
        let width = 4
        let dataspace = await Dataspace(dims: [height, width])
        await dataspace.select(start: [1, 1], stride: [1, 1], count: [3, 2], block: [1, 1])
        let selectionSize = await dataspace.selectionSize
        #expect(selectionSize == 6)
    }

}
