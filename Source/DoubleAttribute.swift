// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

public typealias DoubleAttribute = TypedAttribute<Double>

extension AttributeHost {
    public func createDoubleAttribute(_ name: String, dataspace: Dataspace) -> DoubleAttribute? {
        return createAttribute(name, dataspace: dataspace)
    }

    public func openDoubleAttribute(_ name: String) -> DoubleAttribute? {
        return openAttribute(name)
    }
}
