// Copyright © 2026 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
import Foundation
@testable import HDF5Kit

@HDF5Actor
struct Phase3Tests {
    @Test func datasetAttributes() async throws {
        let filePath = "Tests/Data/test_dataset_attributes.h5"
        try? FileManager.default.removeItem(atPath: filePath)

        let openedFile = try expectHDF5Errors(containing: ["No such file or directory"]) {
            File.open(filePath, mode: .readWrite)
        }
        guard let file = openedFile ?? File.create(filePath, mode: .truncate) else {
            Issue.record("Failed to open or create file")
            return
        }
        
        let dataspace = Dataspace(dims: [10])
        guard let dataset = file.createIntDataset("test", dataspace: dataspace) ?? file.openIntDataset("test") else {
            Issue.record("Failed to create or open dataset")
            return
        }
        
        let attrDataspace = Dataspace(dims: [1])
        guard let attribute = dataset.createIntAttribute("units", dataspace: attrDataspace) ?? dataset.openIntAttribute("units") else {
            Issue.record("Failed to create or open attribute on dataset")
            return
        }
        
        try attribute.write([42])
        let result: [Int] = try attribute.read()
        #expect(result == [42])
    }
    
    @Test func datasetCompression() async throws {
        let filePath = "Tests/Data/test_compression.h5"
        try? FileManager.default.removeItem(atPath: filePath)

        let openedFile = try expectHDF5Errors(containing: ["No such file or directory"]) {
            File.open(filePath, mode: .readWrite)
        }
        guard let file = openedFile ?? File.create(filePath, mode: .truncate) else {
            Issue.record("Failed to open or create file")
            return
        }
        
        let dims = [100, 100]
        let data = [Int](repeating: 1, count: dims[0] * dims[1])
        
        // Create dataset with compression if it doesn't exist
        let dataset: IntDataset
        let openedDataset = try expectHDF5Errors(containing: ["object 'compressed' doesn't exist"]) {
            file.openIntDataset("compressed")
        }
        if let existing = openedDataset {
            dataset = existing
        } else {
            dataset = try file.createAndWriteDataset("compressed", dims: dims, data: data, compression: 9)
        }
        
        // Verify we can read it back
        let readData: [Int] = try dataset.read()
        #expect(readData == data)
    }

    @Test func compressedDatasetUTF8NameDoesNotEmitDiagnostics() async throws {
        let file = createFile(tempFilePath())
        let datasetName = "compressed_café_測定"
        let dims = [4, 4]
        let data = Array(0..<(dims[0] * dims[1]))

        let dataset: IntDataset = try expectNoHDF5Errors {
            try file.createAndWriteDataset(datasetName, dims: dims, data: data, compression: 6)
        }

        let readData: [Int] = try dataset.read()
        #expect(readData == data)

        let openedDataset = try expectNoHDF5Errors {
            file.openIntDataset(datasetName)
        }
        #expect(openedDataset != nil)
        #expect(try openedDataset?.read() == data)
    }
    
    @Test func softLinks() async throws {
        let filePath = "Tests/Data/test_links.h5"
        try? FileManager.default.removeItem(atPath: filePath)

        let openedFile = try expectHDF5Errors(containing: ["No such file or directory"]) {
            File.open(filePath, mode: .readWrite)
        }
        guard let file = openedFile ?? File.create(filePath, mode: .truncate) else {
            Issue.record("Failed to open or create file")
            return
        }
        
        let openedGroup = try expectHDF5Errors(containing: ["object 'group' doesn't exist"]) {
            file.openGroup("group")
        }
        let group = openedGroup ?? file.createGroup("group")
        let dataspace = Dataspace(dims: [5])
        let openedDataset = try expectHDF5Errors(containing: ["object 'data' doesn't exist"]) {
            group.openIntDataset("data")
        }
        _ = openedDataset ?? group.createIntDataset("data", dataspace: dataspace)
        
        // Create soft link if it doesn't exist
        if !file.linkExists("shortcut") {
            try file.createSoftLink(targetPath: "/group/data", linkName: "shortcut")
        }
        
        // Check link exists
        #expect(file.linkExists("shortcut"))
        #expect(!file.linkExists("invalid"))
        
        // Open through link
        let linkedDataset: IntDataset? = file.openDataset("shortcut")
        #expect(linkedDataset != nil)
    }
}
