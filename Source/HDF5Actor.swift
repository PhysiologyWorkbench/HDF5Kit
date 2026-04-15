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
}
