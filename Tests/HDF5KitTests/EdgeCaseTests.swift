// Copyright © 2026 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
@testable import HDF5Kit
import Foundation

@HDF5Actor
struct EdgeCaseTests {

    @Test func testEmptyStringAttribute() async throws {
        let filePath = tempFilePath()
        let file = createFile(filePath)
        
        let attribute = file.createStringAttribute("empty_attr")!
        try attribute.write("")
        
        let result: [String] = try attribute.read()
        #expect(result == [""])
    }

    @Test func testZeroSizedDataspace() async {
        // HDF5 allows 0-sized dimensions in some contexts, but usually they must be at least 1 for simple dataspaces or handled specially.
        // Let's see how our wrapper handles [0].
        let dataspace = Dataspace(dims: [0])
        #expect(dataspace.size == 0)
        #expect(dataspace.dims == [0])
    }

    @Test func testOutOfBoundsHyperslab() async throws {
        let filePath = tempFilePath()
        let file = createFile(filePath)
        
        let dataspace = Dataspace(dims: [10])
        let dataset = file.createIntDataset("small", dataspace: dataspace)!
        
        let fileSpace = dataset.space
        // Select start=15, which is out of bounds for dims=[10]
        fileSpace.select(start: [15], stride: [1], count: [1], block: [1])
        
        let memSpace = Dataspace(dims: [1])
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: 8, alignment: 8)
        defer {
            pointer.deallocate()
        }
        
        // This should throw because H5Dread will fail
        #expect(throws: HDF5Error.self) {
            try expectHDF5Errors(containing: ["selection + offset not within extent"]) {
                try dataset.read(into: pointer, type: .int, memSpace: memSpace, fileSpace: fileSpace)
            }
        }
    }

    @Test func testMissingObject() async throws {
        let filePath = tempFilePath()
        let file = createFile(filePath)
        
        let missingGroup = try expectHDF5Errors(containing: ["object 'non_existent' doesn't exist"]) {
            file.openGroup("non_existent")
        }
        #expect(missingGroup == nil)

        let missingDataset = try expectHDF5Errors(containing: ["object 'non_existent' doesn't exist"]) {
            file.openIntDataset("non_existent")
        }
        #expect(missingDataset == nil)
        
        let invalidFile = try expectHDF5Errors(containing: ["No such file or directory"]) {
            File.open("/non/existent/path/file.h5", mode: .readOnly)
        }
        #expect(invalidFile == nil)
    }
    
    @Test func testEmptyArrayWrite() async throws {
        let filePath = tempFilePath()
        let file = createFile(filePath)
        
        let dataspace = Dataspace(dims: [0], maxDims: [-1])
        let dataset = file.createIntDataset("empty", dataspace: dataspace, chunkDimensions: [10])!
        
        try dataset.write([])
        let result: [Int] = try dataset.read()
        #expect(result.isEmpty)
    }
}
