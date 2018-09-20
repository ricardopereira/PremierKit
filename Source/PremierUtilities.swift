//
//  PremierUtilities.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 19/05/16.
//  Copyright © 2016 Pearland. All rights reserved.
//

import Foundation

public func delay(_ seconds: TimeInterval, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}


// MARK: FileManager

public final class PremierFileManager {

    fileprivate init() {}

    public static func directoryExists(_ manager: Foundation.FileManager = Foundation.FileManager.default, directoryURL: URL) -> Bool {
        return fileExists(manager, fileURL: directoryURL)
    }

    public static func createDirectory(_ manager: Foundation.FileManager = Foundation.FileManager.default, directoryURL: URL) -> Bool {
        if let _ = try? manager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil) {
            return true
        }
        return false
    }

    public static func fileExists(_ manager: Foundation.FileManager = Foundation.FileManager.default, fileURL: URL) -> Bool {
        return manager.fileExists(atPath: fileURL.path)
    }

    public static func createFile(_ manager: Foundation.FileManager = Foundation.FileManager.default, fileURL: URL, data: Data) -> Bool {
        let directoryPath = fileURL.deletingLastPathComponent().path

        guard let _ = try? manager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil) else {
            return false
        }

        return manager.createFile(atPath: fileURL.path, contents: data, attributes: nil)
    }

    public static func removeFile(_ manager: Foundation.FileManager = Foundation.FileManager.default, fileURL: URL?) -> Bool {
        guard let fileURL = fileURL else {
            return true
        }
        do {
            try manager.removeItem(at: fileURL)
            return true
        }
        catch {
            return false
        }
    }

    public static func removeDirectory(_ manager: Foundation.FileManager = Foundation.FileManager.default, directoryURL: URL) -> Bool {
        return removeFile(fileURL: directoryURL)
    }

    public static func renameFile(_ manager: Foundation.FileManager = Foundation.FileManager.default, fileURL: URL, name: String) -> URL? {
        let destinationURL = fileURL.deletingLastPathComponent()
        if moveFile(manager, sourceURL: fileURL, targetURL: destinationURL.appendingPathComponent(name)) {
            return destinationURL.appendingPathComponent(name)
        }
        return nil
    }

    public static func moveFile(_ manager: Foundation.FileManager = Foundation.FileManager.default, sourceURL: URL, targetURL: URL?) -> Bool {
        guard let targetURL = targetURL else {
            return false
        }
        if let _ = try? manager.moveItem(at: sourceURL, to: targetURL) {
            return true
        }
        return false
    }

    public typealias FileName = String
    public static func contentsOfDirectory(_ manager: Foundation.FileManager = Foundation.FileManager.default, directoryURL: URL) -> [FileName] {
        return (try? manager.contentsOfDirectory(atPath: directoryURL.path)) ?? []
    }

    public static func contentsOfFile(_ manager: Foundation.FileManager = Foundation.FileManager.default, fileURL: URL) -> Data? {
        return manager.contents(atPath: fileURL.path)
    }

    public static func attributesOfFile(_ manager: Foundation.FileManager = Foundation.FileManager.default, fileURL: URL?) -> FileAttributes? {
        guard let filePath = fileURL?.path else {
            return nil
        }
        let attributes = (try? manager.attributesOfItem(atPath: filePath)) ?? [:]
        return FileAttributes(
            size: attributes[FileAttributeKey.size] as? Int ?? 0,
            modificationDate: attributes[FileAttributeKey.modificationDate] as? Date ?? Date(),
            creationDate: attributes[FileAttributeKey.creationDate] as? Date ?? Date()
        )
    }

}

public struct FileAttributes {
    let size: Int
    let modificationDate: Date
    let creationDate: Date
}
