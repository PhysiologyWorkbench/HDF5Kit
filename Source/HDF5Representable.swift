// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

/// A protocol for types that can be represented in HDF5.
public protocol HDF5Representable {
    /// The HDF5 NativeType for this type.
    static var hdf5Type: NativeType { get }
}

extension Int: HDF5Representable {
    public static var hdf5Type: NativeType { .int }
}

extension UInt: HDF5Representable {
    public static var hdf5Type: NativeType { .uint }
}

extension Float: HDF5Representable {
    public static var hdf5Type: NativeType { .float }
}

extension Double: HDF5Representable {
    public static var hdf5Type: NativeType { .double }
}

extension Int8: HDF5Representable {
    public static var hdf5Type: NativeType { .int8 }
}

extension UInt8: HDF5Representable {
    public static var hdf5Type: NativeType { .uint8 }
}

extension Int16: HDF5Representable {
    public static var hdf5Type: NativeType { .int16 }
}

extension UInt16: HDF5Representable {
    public static var hdf5Type: NativeType { .uint16 }
}

extension Int32: HDF5Representable {
    public static var hdf5Type: NativeType { .int32 }
}

extension UInt32: HDF5Representable {
    public static var hdf5Type: NativeType { .uint32 }
}

extension Int64: HDF5Representable {
    public static var hdf5Type: NativeType { .int64 }
}

extension UInt64: HDF5Representable {
    public static var hdf5Type: NativeType { .uint64 }
}

extension String: HDF5Representable {
    public static var hdf5Type: NativeType { .opaque } // Handled specially by StringDataset/Attribute
}
