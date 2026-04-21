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
    @HDF5Actor
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

    @HDF5Actor
    static func captureAutomaticErrorMessages<T>(during body: () throws -> T) -> (Result<T, Swift.Error>, [String]) {
        var previousCallback: H5E_auto2_t?
        var previousData: UnsafeMutableRawPointer?
        var capturedMessages = [String]()

        H5Eget_auto2(0, &previousCallback, &previousData)
        let result = withUnsafeMutablePointer(to: &capturedMessages) { messagesPointer in
            H5Eset_auto2(0, HDF5ErrorCaptureCallbacks.captureErrorStack, messagesPointer)
            defer {
                H5Eset_auto2(0, previousCallback, previousData)
            }

            do {
                return Result<T, Swift.Error>.success(try body())
            } catch {
                return Result<T, Swift.Error>.failure(error)
            }
        }

        return (result, capturedMessages)
    }
    
    /// Silences the automatic HDF5 error printing to stderr.
    @HDF5Actor
    public static func silence() {
        // H5E_DEFAULT is usually 0. In some versions it's H5E_DEFAULT_g.
        // We use 0 directly if the constant is not available.
        H5Eset_auto2(0, nil, nil)
    }
}

private enum HDF5ErrorCaptureCallbacks {
    static let captureErrorStack: H5E_auto2_t = { errorStack, data in
        H5Ewalk2(errorStack, H5E_WALK_UPWARD, HDF5ErrorCaptureCallbacks.captureErrorMessage, data)
        return 0
    }

    static let captureErrorMessage: H5E_walk2_t = { _, errorPointer, data in
        guard let error = errorPointer?.pointee,
              let data else {
            return 0
        }

        let messages = data.assumingMemoryBound(to: [String].self)
        let message = String(cString: error.desc)
        let functionName = String(cString: error.func_name)
        messages.pointee.append("\(functionName): \(message)")
        return 0
    }
}
