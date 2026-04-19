// Copyright © 2026 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
import HDF5Kit
import Foundation

struct ConcurrencyTests {

    @Test func testConcurrentDatasetCreation() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<20 {
                group.addTask {
                    let name = "dataset_\(i)"
                    let dataspace = await Dataspace(dims: [10])
                    let dataset = await file.createIntDataset(name, dataspace: dataspace)
                    if dataset == nil {
                        Issue.record("Failed to create dataset \(name)")
                    }
                }
            }
            try await group.waitForAll()
        }

        let names = await file.objectNames()
        #expect(names.count == 20)
    }

    @Test func testConcurrentReadWrite() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)
        let count = 10
        let dataSize = 100

        // Create datasets first
        var datasets = [IntDataset]()
        for i in 0..<count {
            let dataspace = await Dataspace(dims: [dataSize])
            datasets.append(await file.createIntDataset("ds_\(i)", dataspace: dataspace)!)
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<count {
                let dataset = datasets[i]
                let testData = (0..<dataSize).map { _ in Int.random(in: 0...1000) }
                
                group.addTask {
                    // Write
                    try await dataset.write(testData)
                    // Read back
                    let readData: [Int] = try await dataset.read()
                    #expect(readData == testData)
                }
            }
            try await group.waitForAll()
        }
    }
}
