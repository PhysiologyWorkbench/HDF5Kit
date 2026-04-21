# HDF5Kit

![Swift 6.0 compatible](https://img.shields.io/badge/Swift-6.0-orange.svg)

This is a Swift wrapper for the [HDF5](https://www.hdfgroup.org) file format. HDF5 is used in the scientific comunity for managing large volumes of data. The objective is to make it easy to read and write HDF5 files from Swift, including playgrounds.


## Usage

This example shows how to open an existing HDF5 file and write data to an existing dataset.

```swift
import HDF5Kit

// Initialize the data
let dataWidth = 6
let dataHeight = 4
var data = [Double](repeating: 0.0, count: dataHeight * dataWidth)
for r in 0..<dataHeight {
    for c in 0..<dataWidth {
        data[r * dataWidth + c] = Double(r * dataWidth + c + 1)
    }
}

// Open an existing file
let path = "file.h5"
guard let file = File.open(path, mode: .readWrite) else {
    fatalError("Failed to open \(path)")
}

// Open an existing dataset
let datasetName = "dset"
guard let dataset = file.openDoubleDataset(datasetName) else {
    fatalError("Failed to open dataset \(datasetName)")
}

// Write the data
try dataset.write(data)
```

Reading data is really easy with HDF5Kit:

```swift
// Open an existing file
let path = "file.h5"
guard let file = File.open(path, mode: .readWrite) else {
    fatalError("Failed to open \(path)")
}

// Open an existing dataset
let datasetName = "dset"
guard let dataset = file.openStringDataset(datasetName) else {
    fatalError("Failed to open dataset \(datasetName)")
}

let data = dataset[1...3, 2...5]
```

Supported types are: `Double`, `Float`, `Int` and `String`.

## Modernization & New Features

HDF5Kit has been updated for **Swift 6** with several powerful new features and architectural improvements.

### Consolidated Generic API
We have consolidated the type-specific classes into a unified generic system. While `IntDataset`, `DoubleDataset`, etc., are still available as typealiases for backward compatibility, you can now use the generic `Dataset<T>` and `Attribute<T>` where `T: HDF5Representable`.

### Universal Attributes
Attributes can now be attached to **any** HDF5 object, including both Groups and Datasets.
```swift
let dataset = file.createIntDataset("results", dataspace: space)!
let attr = dataset.createStringAttribute("units")!
try attr.write("meters")
```

### Compression Support
You can now easily enable zlib (deflate) compression when creating datasets by passing an optional compression level (0-9).
```swift
// Create a compressed dataset (deflate level 9)
let dataset = try file.createAndWriteDataset("compressed_data", 
                                             dims: [1000, 1000], 
                                             data: largeData, 
                                             compression: 9)
```

### Links API
Support for Soft Links and External Links is now available.
```swift
// Create a soft link (alias) inside the file
try file.createSoftLink(targetPath: "/very/long/path/to/data", 
                        linkName: "shortcut")

if file.linkExists("shortcut") {
    let dataset: DoubleDataset? = file.openDoubleDataset("shortcut")
}
```

### Performance & Safety
- **@HDF5Actor**: All C-API calls are now serialized via a global actor to ensure thread safety with the non-thread-safe libhdf5.
- **Safe Raw Handle Access**: Advanced C interop should use `withUnsafeID { id in ... }` so raw HDF5 identifiers are only accessed while isolated to `@HDF5Actor`. The identifier is owned by HDF5Kit and must not be stored after the closure returns.
- **Improved Error Handling**: Captures descriptive HDF5 error messages for better debugging.
- **Modern Pointers**: Fully updated to use Swift 6 pointer paradigms.

```swift
let objectName = await dataset.withUnsafeID { datasetID in
    // Call lower-level HDF5 C APIs here while serialized by HDF5Kit.
    String(describing: datasetID)
}
```
