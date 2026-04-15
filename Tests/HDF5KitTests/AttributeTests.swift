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
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }
        let group = await file.createGroup("group")
        let name = await group.name
        #expect(name == "/group")

        let dataspace = await Dataspace(dims: [4])
        let attribute = await group.createIntAttribute("attribute", dataspace: dataspace)!
        let attrName = await attribute.name
        #expect(attrName == "attribute")
    }

    @Test func writeReadInt() async throws {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let dataspace = await Dataspace(dims: [1])
        let attribute = await file.createIntAttribute("test", dataspace: dataspace)!
        try await attribute.write([10])

        let result: [Int] = try await attribute.read()
        #expect(result == [10])
    }

    @Test func writeReadFixedString() async throws {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let size = 3
        let attribute = await file.createFixedStringAttribute("test", size: size)!
        try await attribute.write("abc")

        let result: [String] = try await attribute.read()
        #expect(result == ["abc"])
    }

    @Test func writeReadString() async throws {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let attribute = await file.createStringAttribute("test")!
        try await attribute.write("abc")

        let result: [String] = try await attribute.read()
        #expect(result == ["abc"])
    }
}
