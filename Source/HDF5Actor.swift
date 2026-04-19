// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// A global actor used to serialize calls to the non-thread-safe HDF5 C-API.
@globalActor
public final actor HDF5Actor {
    public static let shared = HDF5Actor()
    private init() {}

    /// A global lock to synchronize access to the HDF5 library, even from non-isolated contexts like `deinit`.
    static let lock = NSLock()

    /// Executes a block of code synchronously while holding the global HDF5 lock.
    public static func runSynchronously<T>(_ block: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try block()
    }
}
