// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

public typealias IntAttribute = TypedAttribute<Int>

extension AttributeHost {
    public func createIntAttribute(_ name: String, dataspace: Dataspace) -> IntAttribute? {
        return createAttribute(name, dataspace: dataspace)
    }

    public func openIntAttribute(_ name: String) -> IntAttribute? {
        return openAttribute(name)
    }
}
