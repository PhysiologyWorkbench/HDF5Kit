// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
import HDF5Kit

@HDF5Actor
struct FileTests {
    let width = 100
    let height = 100
    let datasetName = "MyData"

    func writeData(filePath: String, data: [Double]) async throws {
        let file = createFile(filePath)
        let dataspace = Dataspace(dims: [width, height])
        let dataset = file.createDoubleDataset(datasetName, dataspace: dataspace)!
        try dataset.write(data)
    }

    @Test func writeRead() async throws {
        let filePath = tempFilePath()
        let data = (0..<width*height).map { Double($0) }
        try await writeData(filePath: filePath, data: data)

        let file = openFile(filePath)
        let dataset = file.openDoubleDataset(datasetName)!
        let readData = try dataset.read()
        #expect(data == readData)
    }

    @Test func createDataset() async {
        let filePath = tempFilePath()
        let file = createFile(filePath)
        let dims = [width, height]
        let dataspace = Dataspace(dims: [width, height])
        
        let size = dataspace.size
        #expect(size == width * height)
        
        let actualDims = dataspace.dims
        #expect(actualDims == dims)

        let dataset = file.createDoubleDataset(datasetName, dataspace: dataspace)!
        let offset = dataset.offset
        #expect(offset == nil)
    }
}
