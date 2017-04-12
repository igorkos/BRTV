//
//  Diskcached.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/21/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

extension String {

    func escape() -> String {

        let str = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            self as CFString!,
            nil,
            "!*'\"();:@&=+$,/?%#[]% " as CFString!,
            CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))

        return str as! String
    }
}

class Diskcached {

    fileprivate var images = [URL: UIImage]()

    class Directory {
        init() {
            createDirectory()
        }

        fileprivate func createDirectory() {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) {
                return
            }

            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }

        var path: String {
            let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let directoryName = "swift.imageloader.diskcached"

            return cacheDirectory + "/" + directoryName
        }
    }
    let directory = Directory()

    fileprivate let _set_queue = DispatchQueue(label: "swift.imageloader.queues.diskcached.set", attributes: [])
    fileprivate let _subscript_queue = DispatchQueue(label: "swift.imageloader.queues.diskcached.subscript", attributes: DispatchQueue.Attributes.concurrent)
}

// MARK: accessor

extension Diskcached {

    fileprivate func objectForKey(_ aKey: URL) -> UIImage? {

        if let image = images[aKey] {
            return image
        }

        if let data = try? Data(contentsOf: URL(fileURLWithPath: _path(aKey.absoluteString))) {
            return UIImage(data: data)
        }

        return nil
    }

    fileprivate func _path(_ name: String) -> String {
        return directory.path + "/" + name.escape()
    }

    fileprivate func setObject(_ anObject: UIImage, forKey aKey: URL) {

        images[aKey] = anObject

        let block: () -> Void = {

            if let data = UIImageJPEGRepresentation(anObject, 1) {
                try? data.write(to: URL(fileURLWithPath: self._path(aKey.absoluteString)), options: [])
            }

            self.images[aKey] = nil
        }

        _set_queue.async(execute: block)
    }
}

// MARK: ImageLoaderCacheProtocol

extension Diskcached: ImageCache {

    subscript (aKey: URL) -> UIImage? {

        get {
            var value : UIImage?
            _subscript_queue.sync {
                value = self.objectForKey(aKey)
            }

            return value
        }

        set {
            _subscript_queue.async(flags: .barrier, execute: {
                self.setObject(newValue!, forKey: aKey)
            }) 
        }
    }
}
