// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

@HDF5Actor
class AttributeTests: XCTestCase {

    func testName() async {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }
        let group = await file.createGroup("group")
        let name = await group.name
        XCTAssertEqual(name, "/group")

        let dataspace = await Dataspace(dims: [4])
        let attribute = await group.createIntAttribute("attribute", dataspace: dataspace)!
        let attrName = await attribute.name
        XCTAssertEqual(attrName, "attribute")
    }

    func testWriteReadInt() async throws {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let dataspace = await Dataspace(dims: [1])
        let attribute = await file.createIntAttribute("test", dataspace: dataspace)!
        try await attribute.write([10])

        let result: [Int] = try await attribute.read()
        XCTAssertEqual(result, [10])
    }

    func testWriteReadFixedString() async throws {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let size = 3
        let attribute = await file.createFixedStringAttribute("test", size: size)!
        try await attribute.write("abc")

        let result: [String] = try await attribute.read()
        XCTAssertEqual(result, ["abc"])
    }

    func testWriteReadString() async throws {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }

        let attribute = await file.createStringAttribute("test")!
        try await attribute.write("abc")

        let result: [String] = try await attribute.read()
        XCTAssertEqual(result, ["abc"])
    }
}
