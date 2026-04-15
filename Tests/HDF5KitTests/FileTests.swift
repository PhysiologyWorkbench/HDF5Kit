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
        let file = await createFile(filePath)
        let dataspace = await Dataspace(dims: [width, height])
        let dataset = await file.createDoubleDataset(datasetName, dataspace: dataspace)!
        try await dataset.write(data)
    }

    @Test func writeRead() async throws {
        let filePath = await tempFilePath()
        let data = (0..<width*height).map { Double($0) }
        try await writeData(filePath: filePath, data: data)

        let file = await openFile(filePath)
        let dataset = await file.openDoubleDataset(datasetName)!
        let readData = try await dataset.read()
        #expect(data == readData)
    }

    @Test func createDataset() async {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)
        let dims = [width, height]
        let dataspace = await Dataspace(dims: [width, height])
        
        let size = await dataspace.size
        #expect(size == width * height)
        
        let actualDims = await dataspace.dims
        #expect(actualDims == dims)

        let dataset = await file.createDoubleDataset(datasetName, dataspace: dataspace)!
        let offset = await dataset.offset
        #expect(offset == nil)
    }
}
