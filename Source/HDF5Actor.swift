// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// The executor: a serial dispatch queue of the actor's own.
///
/// HDF5Actor serialises every call into the library.
///
/// An earlier version of this executor ran each job on the thread that
/// awaited the actor, under a recursive lock. Therefore, a main-actor
/// caller's `await` ran HDF5's blocking file I/O on the main thread,
/// and any other caller ran it on whichever thread it happened to be on.
/// If it ran on a cooperative-pool thread, which Swift's concurrency runtime
/// expects not to block, the Swift expectations were broken.
///
/// This executor hands every job to a queue the actor owns. Hence,
/// no caller's thread does the library's work.
/// That is what a global actor around a blocking library is for.
///
/// Every call into HDF5Kit is still serialised, through the actor.
/// The public API and the isolation of every type are as they were.
/// A call's result comes back to the caller's own context, as before.
/// HDF5Kit makes no callbacks and holds no assumptions about the main actor,
/// so no caller could observe the thread an awaited call runs on.
/// Existing code should compile and behave as before with no change.
///
/// `runSynchronously` keeps its signature and its purpose.
/// When fired from inside actor code, it is already on the queue and
/// therefore runs its block inline. Fired from any other thread it
/// waits for the queue, as it waited for the lock.
/// A handle's close therefore reaches the library in the same cases as before,
/// from the same places.
///
/// Each `await` into the actor costs a hop to the queue and back, microseconds.
/// The queue runs at `.userInitiated`, so a lower-priority caller's work is
/// raised to that while on it, and a `sync` from the main thread relies on the
/// usual priority inheritance.
private final class HDF5SerialExecutor: SerialExecutor {
    /// Set on the queue, so a block can tell whether it is already running there.
    private static let onQueue = DispatchSpecificKey<Bool>()
    private let queue: DispatchQueue

    init() {
        // User-initiated: a caller is usually waiting for the result.
        queue = DispatchQueue(label: "HDF5Kit.HDF5Actor", qos: .userInitiated)
        queue.setSpecific(key: Self.onQueue, value: true)
    }

    func enqueue(_ job: UnownedJob) {
        queue.async { job.runSynchronously(on: self.asUnownedSerialExecutor()) }
    }

    nonisolated func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }

    func runSynchronously<T>(_ block: () throws -> T) rethrows -> T {
        if DispatchQueue.getSpecific(key: Self.onQueue) == true {
            return try block()
        }
        return try queue.sync(execute: block)
    }
}

/// A global actor used to serialize calls to the non-thread-safe HDF5 C-API.
@globalActor
public final actor HDF5Actor {
    private static let executor = HDF5SerialExecutor()

    public static let shared = HDF5Actor()
    private init() {}

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        Self.executor.asUnownedSerialExecutor()
    }

    /// Executes a block synchronously on the actor's executor,
    /// for code that cannot await, e.g., a `deinit` closing a handle.
    public static func runSynchronously<T>(_ block: () throws -> T) rethrows -> T {
        try executor.runSynchronously(block)
    }
}
