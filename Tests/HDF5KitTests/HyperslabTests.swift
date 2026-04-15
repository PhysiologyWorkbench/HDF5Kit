// Copyright © 2015 Venture Media Labs.
// Copyright © Tim Burgess
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
import HDF5Kit

@HDF5Actor
struct HyperslabTests {
    let datasetName = "MyData"

    @Test func doubleWriteRead() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let dims = [10, 10]
        let dataspace = await Dataspace(dims: dims)
        let dataset = await file.createDoubleDataset(datasetName, dataspace: dataspace)!

        let data = (0..<100).map { Double($0) }
        try await dataset.write(data)

        let readData: [Double] = try await dataset.read()
        #expect(data == readData)
    }

    @Test func slab2DReadDouble() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let dims = [10, 10]
        let dataspace = await Dataspace(dims: dims)
        let dataset = await file.createDoubleDataset(datasetName, dataspace: dataspace)!

        let data = (0..<100).map { Double($0) }
        try await dataset.write(data)

        let fileSpace = await dataset.space
        await fileSpace.select(start: [1, 1], stride: [1, 1], count: [3, 3], block: [1, 1])

        let memSpace = await Dataspace(dims: [3, 3])
        let readData: [Double] = try await dataset.read(memSpace: memSpace, fileSpace: fileSpace)
        #expect(readData.count == 9)
        #expect(readData[0] == 11)
        #expect(readData[1] == 12)
        #expect(readData[2] == 13)
        #expect(readData[3] == 21)
        #expect(readData[4] == 22)
        #expect(readData[5] == 23)
        #expect(readData[6] == 31)
        #expect(readData[7] == 32)
        #expect(readData[8] == 33)
    }

    @Test func slab3DRead() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let dims = [5, 5, 5]
        let dataspace = await Dataspace(dims: dims)
        let dataset = await file.createDoubleDataset(datasetName, dataspace: dataspace)!

        let data = (0..<125).map { Double($0) }
        try await dataset.write(data)

        let fileSpace = await dataset.space
        await fileSpace.select(start: [1, 1, 1], stride: [1, 1, 1], count: [2, 2, 2], block: [1, 1, 1])

        let memSpace = await Dataspace(dims: [2, 2, 2])
        let readData: [Double] = try await dataset.read(memSpace: memSpace, fileSpace: fileSpace)
        #expect(readData.count == 8)
        #expect(readData[0] == 31)
        #expect(readData[1] == 32)
        #expect(readData[2] == 36)
        #expect(readData[3] == 37)
        #expect(readData[4] == 56)
        #expect(readData[5] == 57)
        #expect(readData[6] == 61)
        #expect(readData[7] == 62)
    }

    @Test func stringWriteRead() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let dims = [10]
        let dataspace = await Dataspace(dims: dims)
        let dataset = await file.createStringDataset(datasetName, dataspace: dataspace)!

        let data = (0..<10).map { String($0) }
        try await dataset.write(data)

        let readData: [String] = try await dataset.read()
        #expect(data == readData)
    }

    @Test func readStringSlab() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let dims = [10]
        let dataspace = await Dataspace(dims: dims)
        let dataset = await file.createStringDataset(datasetName, dataspace: dataspace)!

        let data = (0..<10).map { String($0) }
        try await dataset.write(data)

        let fileSpace = await dataset.space
        await fileSpace.select(start: [1], stride: [1], count: [3], block: [1])

        let readData: [String] = try await dataset.read(fileSpace: fileSpace)
        #expect(readData.count == 3)
        #expect(readData[0] == "1")
        #expect(readData[1] == "2")
        #expect(readData[2] == "3")
    }

    @Test func slab2DReadString() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let dims = [10, 10]
        let dataspace = await Dataspace(dims: dims)
        let dataset = await file.createStringDataset(datasetName, dataspace: dataspace)!

        let data = (0..<100).map { String($0) }
        try await dataset.write(data)

        let fileSpace = await dataset.space
        await fileSpace.select(start: [1, 1], stride: [1, 1], count: [3, 3], block: [1, 1])

        let readData: [String] = try await dataset.read(fileSpace: fileSpace)
        #expect(readData.count == 9)
        #expect(readData[0] == "11")
        #expect(readData[1] == "12")
        #expect(readData[2] == "13")
        #expect(readData[3] == "21")
        #expect(readData[4] == "22")
        #expect(readData[5] == "23")
        #expect(readData[6] == "31")
        #expect(readData[7] == "32")
        #expect(readData[8] == "33")
    }
}
