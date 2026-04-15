// Copyright © 2015 Venture Media Labs.
// Copyright © Tim Burgess
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

@HDF5Actor
class HyperslabTests: XCTestCase {
    let datasetName = "MyData"

    func testDoubleWriteRead() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let dims = [10, 10]
        let dataspace = await Dataspace(dims: dims)
        let dataset = await file.createDoubleDataset(datasetName, dataspace: dataspace)!

        let data = (0..<100).map { Double($0) }
        try await dataset.write(data)

        let readData: [Double] = try await dataset.read()
        XCTAssertEqual(data, readData)
    }

    func testSlab2DReadDouble() async throws {
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
        XCTAssertEqual(readData.count, 9)
        XCTAssertEqual(readData[0], 11)
        XCTAssertEqual(readData[1], 12)
        XCTAssertEqual(readData[2], 13)
        XCTAssertEqual(readData[3], 21)
        XCTAssertEqual(readData[4], 22)
        XCTAssertEqual(readData[5], 23)
        XCTAssertEqual(readData[6], 31)
        XCTAssertEqual(readData[7], 32)
        XCTAssertEqual(readData[8], 33)
    }

    func testSlab3DRead() async throws {
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
        XCTAssertEqual(readData.count, 8)
        XCTAssertEqual(readData[0], 31)
        XCTAssertEqual(readData[1], 32)
        XCTAssertEqual(readData[2], 36)
        XCTAssertEqual(readData[3], 37)
        XCTAssertEqual(readData[4], 56)
        XCTAssertEqual(readData[5], 57)
        XCTAssertEqual(readData[6], 61)
        XCTAssertEqual(readData[7], 62)
    }

    func testStringWriteRead() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let dims = [10]
        let dataspace = await Dataspace(dims: dims)
        let dataset = await file.createStringDataset(datasetName, dataspace: dataspace)!

        let data = (0..<10).map { String($0) }
        try await dataset.write(data)

        let readData: [String] = try await dataset.read()
        XCTAssertEqual(data, readData)
    }

    func testReadStringSlab() async throws {
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
        XCTAssertEqual(readData.count, 3)
        XCTAssertEqual(readData[0], "1")
        XCTAssertEqual(readData[1], "2")
        XCTAssertEqual(readData[2], "3")
    }

    func testSlab2DReadString() async throws {
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
        XCTAssertEqual(readData.count, 9)
        XCTAssertEqual(readData[0], "11")
        XCTAssertEqual(readData[1], "12")
        XCTAssertEqual(readData[2], "13")
        XCTAssertEqual(readData[3], "21")
        XCTAssertEqual(readData[4], "22")
        XCTAssertEqual(readData[5], "23")
        XCTAssertEqual(readData[6], "31")
        XCTAssertEqual(readData[7], "32")
        XCTAssertEqual(readData[8], "33")
    }
}
