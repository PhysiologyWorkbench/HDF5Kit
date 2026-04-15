# Modernising HDF5Kit

Based on a deep review of the HDF5Kit source code, it's clear that this library was built as a solid, functional wrapper for the libhdf5 C-API, but it is deeply anchored in Swift 3/4 paradigms.

Here is a comprehensive specialist review identifying the architectural shortcomings, incomplete features compared to the underlying libhdf5, and a concrete action plan for updating the library to Swift 6 while preserving API compatibility.

  1. Architectural & Swift 6 Modernization Opportunities

   * Eliminate Massive Code Duplication with Generics: The library currently relies on duplicating entire classes and extensions for every supported type (e.g., IntDataset, DoubleDataset, FloatDataset, StringDataset, and their Attribute counterparts). Swift 6’s advanced generics easily handle this. We can create a unified ValueDataset<T: HDF5Representable> and use typealias IntDataset = ValueDataset<Int> to maintain 100% backward compatibility for existing users.
   * ~Copyable Types for Resource Management: Currently, Object, Dataspace, Datatype, File, etc., are defined as class just to hook into deinit for H5*close calls (e.g., H5Fclose(id)). In Swift 6, we can use noncopyable (~Copyable) structs to wrap hid_t. This eliminates reference-counting (ARC) overhead entirely while guaranteeing deterministic cleanup, significantly improving performance for high-throughput I/O operations.
   * Strict Concurrency (Sendable & Actors): Swift 6 enforces strict concurrency. The libhdf5 C-API is notoriously not thread-safe by default (unless specifically compiled with --enable-threadsafe). The current wrapper has no thread-safety guarantees. We should introduce @HDF5Actor (a global actor) to serialize C-API calls, or at least properly mark immutable wrapper types as Sendable and document thread constraints to pass Swift 6 concurrency checks.
   * Typed Throws & Better Error Reporting: The current error handling catches any failure (e.g., status < 0) and throws a generic Error.ioError. Swift 6 introduces Typed Throws. We can wrap H5E (the HDF5 error API) to extract the actual C error string and throw a strongly-typed HDF5Error, allowing developers to actually debug why a read/write failed.
   * Variadic Subscript Bug: IntDataset.swift contains a workaround: "There is a problem with Swift where it gives a compiler error if set is implemented here" for subscript(slices: HyperslabIndexType...). This bug was fixed years ago in the Swift compiler. We can restore full variadic subscript capabilities.
   * Pointer Safety: Swift 6 has deprecated certain implicit pointer conversions and memory rebinding techniques used in the codebase (like using withUnsafeMutableBufferPointer to cast types or passing arrays to UnsafePointer). These need to be updated to modern UnsafeRawBufferPointer paradigms.

  2. Incomplete / Missing libhdf5 Features

  While the library covers basic Groups, Datasets, and Dataspaces, it leaves out several of the most powerful features of HDF5:

   * Attributes on Datasets: Attributes (H5A) are currently implemented as an extension on GroupType (which applies to File and Group). However, in HDF5, attributes can be attached to any object, most notably Datasets. The current API does not allow adding an attribute (like "units" or "calibration_factor") directly to a Dataset.
   * Filters & Compression: The library supports chunking (chunkSize), but it completely misses the property lists (H5P) required to enable compression. HDF5’s built-in zlib (deflate) and szip compression are heavily relied upon in data science. Exposing H5Pset_deflate is a high-priority missing feature.
   * Links (H5L API): There is no support for Soft Links (aliases inside the file), Hard Links, or External Links (linking to datasets in other .h5 files).
   * Advanced Datatypes:
       * Compound Types (H5T_COMPOUND): Missing. HDF5 allows mapping complex C-structs (or Swift structs) to tables.
       * Variable-Length Arrays / Strings: Mostly missing or incomplete.
       * Enums (H5T_ENUM): Missing.
   * Object References: HDF5 allows datasets to contain pointers/references (H5R) to other datasets or regions within datasets. This is currently unsupported.

  ---

  3. Proposed Action Plan

  To transition this to a modern Swift 6 library seamlessly, we should execute the following steps:

  Phase 1: Foundation & Swift 6 Compliance (No API changes)
   1. Update Project Settings: Migrate Package.swift and Xcode projects to Swift 6.
   2. Pointer & Warning Cleanup: Fix all deprecated UnsafePointer and withCString warnings. Resolve the variadic subscript set bug.
   3. Error Handling Upgrade: Integrate the H5E error stack to capture underlying C errors and throw detailed error messages instead of generic I/O errors, optionally adopting Swift 6 Typed Throws.
   4. Concurrency Annotations: Apply @preconcurrency import CHDF5 and audit for Sendable conformance where safe, preparing users for strict concurrency mode.

  Phase 2: Code Consolidation (Preserving API via Typealiases)
   1. Generic Type Implementation: Create Attribute<T> and Dataset<T> utilizing a new HDF5Representable protocol (which maps Swift types to NativeType).
   2. Deprecate & Alias: Replace the duplicated files (IntDataset.swift, DoubleDataset.swift, etc.) with typealias IntDataset = Dataset<Int>. Users will see no breaking changes, but the codebase will shrink by ~60%.
   3. ~Copyable handles: Refactor the underlying hid_t storage to use Swift 6 noncopyable structs to drastically improve performance under heavy load, keeping the outer API class-based if reference semantics are strictly expected by consumers.

  Phase 3: Filling the Feature Gaps (Additive API changes)
   1. Universal Attributes: Move the create...Attribute and open...Attribute methods to a new AttributeHost protocol, and make both GroupType and Dataset conform to it.
   2. Compression Support: Add an optional compression: Int? (deflate level 0-9) parameter to the dataset creation APIs (createDataset). If provided, configure the H5P property list with H5Pset_deflate before passing it to H5Dcreate2.
   3. Links API: Expose basic H5L commands to create and traverse soft and external links.

  Implementing this plan will elevate HDF5Kit from an outdated Swift 4 wrapper into a highly performant, type-safe, and modern Swift 6 library, without forcing existing dependents to rewrite their integration code.
  
# Progress 

- [x] Comprehensive review of the codebase and identification of architectural shortcomings.
- [x] Proposed action plan for Swift 6 modernisation.
- [ ] Phase 1: Foundation & Swift 6 Compliance
- [ ] Phase 2: Code Consolidation (Preserving API via Typealiases)
- [ ] Phase 3: Filling the Feature Gaps (Additive API changes)