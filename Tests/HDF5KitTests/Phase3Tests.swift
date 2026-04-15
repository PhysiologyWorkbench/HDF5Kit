// Copyright © 2026 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
@testable import HDF5Kit

@HDF5Actor
struct Phase3Tests {
    @Test func datasetAttributes() async throws {
        let filePath = "test_dataset_attributes.h5"
        guard let file = File.create(filePath, mode: .truncate) else {
            Issue.record("Failed to create file")
            return
        }
        
        let dataspace = Dataspace(dims: [10])
        guard let dataset = file.createIntDataset("test", dataspace: dataspace) else {
            Issue.record("Failed to create dataset")
            return
        }
        
        let attrDataspace = Dataspace(dims: [1])
        guard let attribute = dataset.createIntAttribute("units", dataspace: attrDataspace) else {
            Issue.record("Failed to create attribute on dataset")
            return
        }
        
        try attribute.write([42])
        let result: [Int] = try attribute.read()
        #expect(result == [42])
    }
    
    @Test func datasetCompression() async throws {
        let filePath = "test_compression.h5"
        guard let file = File.create(filePath, mode: .truncate) else {
            Issue.record("Failed to create file")
            return
        }
        
        let dims = [100, 100]
        let data = [Int](repeating: 1, count: dims[0] * dims[1])
        
        // Create dataset with compression
        let dataset = try file.createAndWriteDataset("compressed", dims: dims, data: data, compression: 9)
        
        // Verify we can read it back
        let readData: [Int] = try dataset.read()
        #expect(readData == data)
    }
    
    @Test func softLinks() async throws {
        let filePath = "test_links.h5"
        guard let file = File.create(filePath, mode: .truncate) else {
            Issue.record("Failed to create file")
            return
        }
        
        let group = file.createGroup("group")
        let dataspace = Dataspace(dims: [5])
        _ = group.createIntDataset("data", dataspace: dataspace)
        
        // Create soft link
        try file.createSoftLink(targetPath: "/group/data", linkName: "shortcut")
        
        // Check link exists
        #expect(file.linkExists("shortcut"))
        #expect(!file.linkExists("invalid"))
        
        // Open through link
        let linkedDataset: IntDataset? = file.openDataset("shortcut")
        #expect(linkedDataset != nil)
    }
}
