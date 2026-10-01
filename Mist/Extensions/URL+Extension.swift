//
//  URL+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 17/6/2022.
//

import CryptoKit
import Foundation

extension URL {
    /// Creates a URL for the provided default directory path, or `nil` if the path is empty or is no longer an existing directory.
    ///
    /// - Parameters:
    ///   - defaultDirectory: The default directory path stored in user defaults.
    init?(defaultDirectory: String) {
        var isDirectory: ObjCBool = false

        guard
            !defaultDirectory.isEmpty,
            FileManager.default.fileExists(atPath: defaultDirectory, isDirectory: &isDirectory),
            isDirectory.boolValue else {
            return nil
        }

        self.init(fileURLWithPath: defaultDirectory, isDirectory: true)
    }

    /// Provides the size of the file at the URL, in bytes.
    ///
    /// - Throws: An `Error` if the file size is unable to be determined.
    ///
    /// - Returns: The file size of the provided URL, in bytes.
    func fileSize() throws -> UInt64 {
        let urlResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey
        ]

        let resourceValues: URLResourceValues = try resourceValues(forKeys: urlResourceKeys)

        guard
            let isRegularFile: Bool = resourceValues.isRegularFile,
            isRegularFile else {
            return 0
        }

        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }

    /// Provides the SHA1 hash of the file at the URL.
    ///
    /// - Returns: The SHA1 hash of the file at the provided URL, or `nil` if a has is unable to be determined.
    func shasum() -> String? {
        let length: Int = 1_024 * 1_024 * 50 // 50 MB

        do {
            let fileHandle: FileHandle = try FileHandle(forReadingFrom: self)

            defer {
                fileHandle.closeFile()
            }

            var shasum: Insecure.SHA1 = .init()

            while
                try autoreleasepool(invoking: {
                    try Task.checkCancellation()
                    let data: Data = fileHandle.readData(ofLength: length)

                    if !data.isEmpty {
                        shasum.update(data: data)
                    }

                    return !data.isEmpty
                }) {}

            let data: Data = .init(shasum.finalize())
            return data.map { String(format: "%02hhx", $0) }.joined()
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
