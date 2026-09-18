// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Testing
import HDF5Kit

@HDF5Actor
struct AttributeTests {

    @Test func name() async {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }
        let group = file.createGroup("group")
        let name = group.name
        #expect(name == "/group")

        let dataspace = Dataspace(dims: [4])
        let attribute = group.createIntAttribute("attribute", dataspace: dataspace)!
        let attrName = attribute.name
        #expect(attrName == "attribute")
    }

    @Test func writeReadInt() async throws {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let dataspace = Dataspace(dims: [1])
        let attribute = file.createIntAttribute("test", dataspace: dataspace)!
        try attribute.write([10])

        let result: [Int] = try attribute.read()
        #expect(result == [10])
    }

    @Test func writeReadFixedString() async throws {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let size = 3
        let attribute = file.createFixedStringAttribute("test", size: size)!
        try attribute.write("abc")

        let result: [String] = try attribute.read()
        #expect(result == ["abc"])
    }

    @Test func writeReadString() async throws {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let attribute = file.createStringAttribute("test")!
        try attribute.write("abc")

        #expect(attribute.space.dims == [1])
        let result: [String] = try attribute.read()
        #expect(result == ["abc"])
    }

    /// A scalar string attribute - rank 0, not a one-element array. Readers of
    /// formats that specify scalar text need the distinction: `h5py` hands a
    /// one-element attribute back as an array.
    @Test func writeReadScalarString() async throws {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let attribute = file.createStringAttribute("test", dataspace: Dataspace(dims: []))!
        try attribute.write("abc")

        #expect(attribute.space.ndims == 0)
        #expect(attribute.space.size == 1)
        let result: [String] = try attribute.read()
        #expect(result == ["abc"])
    }
}
