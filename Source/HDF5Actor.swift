// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

private final class HDF5SerialExecutor: SerialExecutor {
    private let lock = NSRecursiveLock()

    func enqueue(_ job: UnownedJob) {
        lock.lock()
        defer { lock.unlock() }
        job.runSynchronously(on: asUnownedSerialExecutor())
    }

    nonisolated func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }

    func runSynchronously<T>(_ block: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try block()
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

    /// Executes a block synchronously on the same lock used by the global actor executor.
    public static func runSynchronously<T>(_ block: () throws -> T) rethrows -> T {
        try executor.runSynchronously(block)
    }
}
