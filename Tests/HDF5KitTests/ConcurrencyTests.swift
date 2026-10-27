// Copyright © 2026 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
import HDF5Kit
import Foundation

@HDF5Actor private func actorRunsOnTheMainThread() -> Bool { pthread_main_np() != 0 }
@HDF5Actor private func runSynchronouslyFromTheActor() -> Bool { HDF5Actor.runSynchronously { true } }
/// Written by a job on the actor and read inside `runSynchronously`, which
/// the queue orders after that job.
nonisolated(unsafe) private var jobHasFinished = false
/// Occupies the actor for a while, signalling when it has started.
@HDF5Actor private func occupyTheActor(signalling started: DispatchSemaphore) {
    started.signal()
    Thread.sleep(forTimeInterval: 0.2)
    jobHasFinished = true
}

struct ConcurrencyTests {

    /// The actor's jobs run on its own queue, not on the thread that awaits
    /// them: a main-actor caller's `await` does not put HDF5 on the main
    /// thread.
    @MainActor @Test func testActorJobsLeaveTheCallingThread() async {
        #expect(pthread_main_np() != 0)
        #expect(await actorRunsOnTheMainThread() == false)
    }

    /// `runSynchronously` from inside actor code — a `deinit` fired there —
    /// runs inline and returns, rather than waiting on the queue it is on.
    @Test(.timeLimit(.minutes(1))) func testRunSynchronouslyInsideTheActorDoesNotDeadlock() async {
        #expect(await runSynchronouslyFromTheActor())
    }

    /// `runSynchronously` from outside actor code — a `deinit` fired on any
    /// other thread — waits for the queue and returns.
    @Test(.timeLimit(.minutes(1))) func testRunSynchronouslyFromOutsideTheActorReturns() {
        #expect(HDF5Actor.runSynchronously { true })
    }

    /// `runSynchronously` from another thread waits for the job the actor is
    /// running rather than running beside it: the exclusion the lock gave.
    @Test(.timeLimit(.minutes(1))) func testRunSynchronouslyWaitsForTheRunningJob() {
        let started = DispatchSemaphore(value: 0)
        jobHasFinished = false
        Task { @HDF5Actor in occupyTheActor(signalling: started) }
        started.wait()
        #expect(HDF5Actor.runSynchronously { jobHasFinished })
    }

    /// The last reference to a file dropped on the main actor closes it
    /// there, through `runSynchronously` from off the queue, without a
    /// deadlock; HDF5 then lets the file be truncated.
    @MainActor @Test(.timeLimit(.minutes(1))) func testLastReferenceDroppedOnTheMainActorClosesTheFile() async {
        let filePath = await tempFilePath()
        var file: File? = await createFile(filePath)
        file = nil
        _ = file
        #expect(await File.create(filePath, mode: .truncate) != nil)
    }

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

    @Test func testRawIDAccessUsesActorIsolatedClosure() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)

        let hasValidID = await file.withUnsafeID { $0 >= 0 }

        #expect(hasValidID)
    }

    @Test func testConcurrentTeardownAndOperations() async throws {
        let filePath = await tempFilePath()
        let file = await createFile(filePath)
        let datasetCount = 50
        let dataSize = 16

        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<datasetCount {
                group.addTask {
                    let dataspace = await Dataspace(dims: [dataSize])
                    guard let dataset = await file.createIntDataset("transient_\(index)", dataspace: dataspace) else {
                        Issue.record("Failed to create transient dataset \(index)")
                        return
                    }

                    let values = Array(repeating: index, count: dataSize)
                    try await dataset.write(values)
                    let readValues: [Int] = try await dataset.read()
                    #expect(readValues == values)
                }
            }

            group.addTask {
                for _ in 0..<datasetCount {
                    _ = await file.objectNames()
                    await Task.yield()
                }
            }

            try await group.waitForAll()
        }

        let names = await file.objectNames()
        #expect(names.filter { $0.hasPrefix("transient_") }.count == datasetCount)
    }
}
