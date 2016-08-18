//
//  PremierUtilities.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 19/05/16.
//  Copyright © 2016 Pearland. All rights reserved.
//

import Foundation

public func delay(seconds: NSTimeInterval, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(seconds * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(),
        closure
    )
}


// MARK: FileManager

public struct FileManager {

    private init() {}

    public static func directoryExists(manager: NSFileManager = NSFileManager.defaultManager(), directoryURL: NSURL) -> Bool {
        return fileExists(manager, fileURL: directoryURL)
    }

    public static func createDirectory(manager: NSFileManager = NSFileManager.defaultManager(), directoryURL: NSURL) -> Bool {
        if let path = directoryURL.path, _ = try? manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil) {
            return true
        }
        return false
    }

    public static func fileExists(manager: NSFileManager = NSFileManager.defaultManager(), fileURL: NSURL) -> Bool {
        if let path = fileURL.path {
            return manager.fileExistsAtPath(path)
        }
        return false
    }

    public static func createFile(manager: NSFileManager = NSFileManager.defaultManager(), fileURL: NSURL, data: NSData) -> Bool {
        guard let directoryPath = fileURL.URLByDeletingLastPathComponent?.path else {
            return false
        }

        guard let _ = try? manager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil) else {
            return false
        }

        guard let filePath = fileURL.path else {
            return false
        }
        return manager.createFileAtPath(filePath, contents: data, attributes: nil)
    }

    public static func removeFile(manager: NSFileManager = NSFileManager.defaultManager(), fileURL: NSURL?) -> Bool {
        guard let fileURL = fileURL else {
            return true
        }
        do {
            try manager.removeItemAtURL(fileURL)
            return true
        }
        catch {
            return false
        }
    }

    public static func removeDirectory(manager: NSFileManager = NSFileManager.defaultManager(), directoryURL: NSURL) -> Bool {
        return removeFile(fileURL: directoryURL)
    }

    public static func renameFile(manager: NSFileManager = NSFileManager.defaultManager(), fileURL: NSURL, name: String) -> NSURL? {
        if let destinationURL = fileURL.URLByDeletingLastPathComponent where moveFile(manager, sourceURL: fileURL, targetURL: destinationURL.URLByAppendingPathComponent(name)) {
            return destinationURL.URLByAppendingPathComponent(name)
        }
        return nil
    }

    public static func moveFile(manager: NSFileManager = NSFileManager.defaultManager(), sourceURL: NSURL, targetURL: NSURL) -> Bool {
        if let _ = try? manager.moveItemAtURL(sourceURL, toURL: targetURL) {
            return true
        }
        return false
    }

    public typealias FileName = String
    public static func contentsOfDirectory(manager: NSFileManager = NSFileManager.defaultManager(), directoryURL: NSURL) -> [FileName] {
        guard let directoryPath = directoryURL.path else {
            return []
        }
        return (try? manager.contentsOfDirectoryAtPath(directoryPath)) ?? []
    }

    public static func contentsOfFile(manager: NSFileManager = NSFileManager.defaultManager(), fileURL: NSURL) -> NSData? {
        guard let filePath = fileURL.path else {
            return nil
        }
        return manager.contentsAtPath(filePath)
    }

    public static func attributesOfFile(manager: NSFileManager = NSFileManager.defaultManager(), fileURL: NSURL?) -> FileAttributes? {
        guard let filePath = fileURL?.path else {
            return nil
        }
        let attributes = (try? manager.attributesOfItemAtPath(filePath)) ?? [:]
        return FileAttributes(
            size: attributes[NSFileSize] as? Int ?? 0,
            modificationDate: attributes[NSFileModificationDate] as? NSDate ?? NSDate(),
            creationDate: attributes[NSFileCreationDate] as? NSDate ?? NSDate()
        )
    }

}

public struct FileAttributes {
    let size: Int
    let modificationDate: NSDate
    let creationDate: NSDate
}
