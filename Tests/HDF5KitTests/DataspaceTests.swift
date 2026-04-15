// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

@HDF5Actor
class DataspaceTests: XCTestCase {

    func testDimensions() async {
        let height = 10
        let width = 4
        let dataspace = await Dataspace(dims: [height, width], maxDims: [-1, -1])
        let dims = await dataspace.dims
        XCTAssertEqual(dims.count, 2)
        XCTAssertEqual(dims[0], height)
        XCTAssertEqual(dims[1], width)
    }

    func testMaxDimensions() async {
        let height = 10
        let width = 4
        let dataspace = await Dataspace(dims: [height, width], maxDims: [-1, -1])
        let maxDims = await dataspace.maxDims
        XCTAssertEqual(maxDims.count, 2)
        XCTAssertEqual(maxDims[0], -1)
        XCTAssertEqual(maxDims[1], -1)
    }

    func testSelect() async {
        let height = 10
        let width = 4
        let dataspace = await Dataspace(dims: [height, width])
        await dataspace.select(start: [1, 1], stride: [1, 1], count: [3, 2], block: [1, 1])
        let selectionSize = await dataspace.selectionSize
        XCTAssertEqual(selectionSize, 6)
    }

}
