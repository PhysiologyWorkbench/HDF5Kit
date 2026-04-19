// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    @preconcurrency import CHDF5
#endif

public enum HDF5Error: Swift.Error, CustomStringConvertible {
    case ioError(description: String)

    public var description: String {
        switch self {
        case .ioError(let description):
            return description
        }
    }

    /// Captures the current HDF5 error stack and returns an HDF5Error.
    static func lastError() -> HDF5Error {
        var messages = [String]()

        let callback: @convention(c) (UInt32, UnsafePointer<H5E_error2_t>?, UnsafeMutableRawPointer?) -> herr_t = { (index, errorPointer, data) in
            guard let error = errorPointer?.pointee else { return 0 }
            let msg = String(cString: error.desc)
            let funcName = String(cString: error.func_name)
            
            // Access the pointer to the messages array passed in 'data'
            let messagesPtr = data?.assumingMemoryBound(to: [String].self)
            messagesPtr?.pointee.append("\(funcName): \(msg)")
            return 0
        }

        let errorStack = H5Eget_current_stack()
        defer { H5Eclose_stack(errorStack) }

        _ = withUnsafeMutablePointer(to: &messages) { messagesPtr in
            H5Ewalk2(errorStack, H5E_WALK_UPWARD, callback, messagesPtr)
        }

        if messages.isEmpty {
            return .ioError(description: "HDF5 error occurred (no details available).")
        } else {
            return .ioError(description: messages.joined(separator: "\n"))
        }
    }
    
    /// Silences the automatic HDF5 error printing to stderr.
    public static func silence() {
        // H5E_DEFAULT is usually 0. In some versions it's H5E_DEFAULT_g.
        // We use 0 directly if the constant is not available.
        H5Eset_auto2(0, nil, nil)
    }
}
