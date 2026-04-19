// Copyright © 2015 Venture Media Labs.
// Copyright © 2015 Tim Burgess
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
import HDF5Kit

@HDF5Actor
struct IndexingTests {
    static let datasetName = "MyData"
    static let datasetDims = [3, 3]
    static let datasetSize = datasetDims.reduce(1, *)
    static let datasetDoubleData = (0..<datasetSize).map { Double($0) }
    static let datasetIntData = (0..<datasetSize).map { Int($0) }
    static let datasetStringData = (0..<datasetSize).map { String($0) }

    var filePath: String
    var file: File

    init() async {
        let path = tempFilePath()
        self.filePath = path
        self.file = createFile(path)
    }

    @Test func allReadDouble() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[HyperslabIndex.all, HyperslabIndex.all]
        #expect(readData == IndexingTests.datasetDoubleData)
    }

    @Test func sliceMiddleValue() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[1, 1]
        #expect(readData == [4.0])
    }

    @Test func sliceMiddleRow() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[1, HyperslabIndex.all]
        #expect(readData == [3.0, 4.0, 5.0])
    }

    @Test func sliceLastColumn() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[HyperslabIndex.all, 2]
        #expect(readData == [2.0, 5.0, 8.0])
    }

    @Test func sliceFirstTwoRowsDouble() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[0...1, HyperslabIndex.all]
        #expect(readData == [0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    }

    @Test func sliceLastTwoRows() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[1...2, HyperslabIndex.all]
        #expect(readData == [3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    }

    @Test func sliceFirstTwoColumnsDouble() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[HyperslabIndex.all, 0...1]
        #expect(readData == [0.0, 1.0, 3.0, 4.0, 6.0, 7.0])
    }

    @Test func sliceLastTwoColumns() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[HyperslabIndex.all, 1...2]
        #expect(readData == [1.0, 2.0, 4.0, 5.0, 7.0, 8.0])
    }

    @Test func sliceLastTwoColumnsOfLastTwoRows() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
        let readData: [Double] = dataset[1...2, 1...2]
        #expect(readData == [4.0, 5.0, 7.0, 8.0])
    }

    @Test func allReadInt() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetIntData)
        let readData: [Int] = dataset[HyperslabIndex.all, HyperslabIndex.all]
        #expect(readData == IndexingTests.datasetIntData)
    }

    @Test func sliceFirstTwoRowsInt() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetIntData)
        let readData: [Int] = dataset[0...1, HyperslabIndex.all]
        #expect(readData == [0, 1, 2, 3, 4, 5])
    }

    @Test func sliceFirstTwoColumnsInt() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetIntData)
        let readData: [Int] = dataset[HyperslabIndex.all, 0...1]
        #expect(readData == [0, 1, 3, 4, 6, 7])
    }

    @Test func allReadString() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetStringData)
        let readData: [String] = dataset[HyperslabIndex.all, HyperslabIndex.all]
        #expect(readData == IndexingTests.datasetStringData)
    }

    @Test func sliceFirstTwoRowsString() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetStringData)
        let readData: [String] = dataset[0...1, HyperslabIndex.all]
        #expect(readData == ["0", "1", "2", "3", "4", "5"])
    }

    @Test func sliceFirstTwoColumnsString() async throws {
        let dataset = try file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetStringData)
        let readData: [String] = dataset[HyperslabIndex.all, 0...1]
        #expect(readData == ["0", "1", "3", "4", "6", "7"])
    }
}
