// Copyright © 2015 Venture Media Labs.
// Copyright © 2015 Tim Burgess
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

@HDF5Actor
class IndexingTests: XCTestCase {
    static let datasetName = "MyData"
    static let datasetDims = [3, 3]
    static let datasetSize = datasetDims.reduce(1, *)
    static let datasetDoubleData = (0..<datasetSize).map { Double($0) }
    static let datasetIntData = (0..<datasetSize).map { Int($0) }
    static let datasetStringData = (0..<datasetSize).map { String($0) }

    var filePath: String!
    var file: File!

    override func setUp() async throws {
        try await super.setUp()
        filePath = await tempFilePath()
        file = await createFile(filePath)
    }

    func testAllReadDouble() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[HyperslabIndex.all, HyperslabIndex.all]
        XCTAssertEqual(readData, IndexingTests.datasetDoubleData)
    }

    func testSliceMiddleValue() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[1, 1]
        XCTAssertEqual(readData, [4.0])
    }

    func testSliceMiddleRow() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[1, HyperslabIndex.all]
        XCTAssertEqual(readData, [3.0, 4.0, 5.0])
    }

    func testSliceLastColumn() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[HyperslabIndex.all, 2]
        XCTAssertEqual(readData, [2.0, 5.0, 8.0])
    }

    func testSliceFirstTwoRowsDouble() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[0...1, HyperslabIndex.all]
        XCTAssertEqual(readData, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    }

    func testSliceLastTwoRows() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[1...2, HyperslabIndex.all]
        XCTAssertEqual(readData, [3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    }

    func testSliceFirstTwoColumnsDouble() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[HyperslabIndex.all, 0...1]
        XCTAssertEqual(readData, [0.0, 1.0, 3.0, 4.0, 6.0, 7.0])
    }

    func testSliceLastTwoColumns() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[HyperslabIndex.all, 1...2]
        XCTAssertEqual(readData, [1.0, 2.0, 4.0, 5.0, 7.0, 8.0])
    }

    func testSliceLastTwoColumnsOfLastTwoRows() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[1...2, 1...2]
        XCTAssertEqual(readData, [4.0, 5.0, 7.0, 8.0])
    }

    func testAllReadInt() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetIntData)
        let readData: [Int] = dataset[HyperslabIndex.all, HyperslabIndex.all]
        XCTAssertEqual(readData, IndexingTests.datasetIntData)
    }

    func testSliceFirstTwoRowsInt() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetIntData)
        let readData: [Int] = dataset[0...1, HyperslabIndex.all]
        XCTAssertEqual(readData, [0, 1, 2, 3, 4, 5])
    }

    func testSliceFirstTwoColumnsInt() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetIntData)
        let readData: [Int] = dataset[HyperslabIndex.all, 0...1]
        XCTAssertEqual(readData, [0, 1, 3, 4, 6, 7])
    }

    func testAllReadString() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetStringData)
        let readData: [String] = dataset[HyperslabIndex.all, HyperslabIndex.all]
        XCTAssertEqual(readData, IndexingTests.datasetStringData)
    }

    func testSliceFirstTwoRowsString() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetStringData)
        let readData: [String] = dataset[0...1, HyperslabIndex.all]
        XCTAssertEqual(readData, ["0", "1", "2", "3", "4", "5"])
    }

    func testSliceFirstTwoColumnsString() async throws {
        let dataset = try await file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetStringData)
        let readData: [String] = dataset[HyperslabIndex.all, 0...1]
        XCTAssertEqual(readData, ["0", "1", "3", "4", "6", "7"])
    }
}
