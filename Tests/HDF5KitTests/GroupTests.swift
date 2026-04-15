// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

@HDF5Actor
class GroupTests: XCTestCase {

    func testName() async {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }
        let group = await file.createGroup("group")
        let name = await group.name
        XCTAssertEqual(name, "/group")
    }

    func testObjectNames() async {
        let filePath = await tempFilePath()
        guard let file = await File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }
        _ = await file.createGroup("group1")
        _ = await file.createGroup("group2")

        let names = await file.objectNames()
        XCTAssertEqual(names.count, 2)
        XCTAssertTrue(names.contains("group1"))
        XCTAssertTrue(names.contains("group2"))
    }
}
