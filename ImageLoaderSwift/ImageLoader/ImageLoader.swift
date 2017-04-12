//
//  ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/16/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

public protocol URLLiteralConvertible {
    var imageLoaderURL: URL { get }
}

extension URL: URLLiteralConvertible {
    public var imageLoaderURL: URL {
        return self
    }
}

extension URLComponents: URLLiteralConvertible {
    public var imageLoaderURL: URL {
        return url!
    }
}

extension String: URLLiteralConvertible {
    public var imageLoaderURL: URL {
        if let string = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: string)!
        }
        return URL(string: self)!
    }
}

extension UIImage {

    func adjusts(_ size: CGSize, scale: CGFloat) -> UIImage? {
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: Cache

/**
    Cache for `ImageLoader` have to implement methods.
    fetch image by cache before sending a request and set image into cache after receiving image data.
*/
public protocol ImageCache: class {

    subscript (aKey: URL) -> UIImage? {
        get
        set
    }

}

public typealias CompletionHandler = (URL, UIImage?, NSError?, CacheType) -> Void

class Block: NSObject {

    let completionHandler: CompletionHandler
    init(completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

}

/**
    Use to check state of loaders that manager has.
    Ready:      The manager have no loaders
    Running:    The manager has loaders, and they are running
    Suspended:  The manager has loaders, and their states are all suspended
*/
public enum State {
    case ready
    case running
    case suspended
}

/**
    Use to check where image is loaded from.
    None:   fetching from network
    Cache:  getting from `ImageCache`
*/
public enum CacheType {
    case none
    case cache
}

/**
    Responsible for creating and managing `Loader` objects and controlling of `NSURLSession` and `ImageCache`
*/
open class Manager {

    let session: URLSession
    let cache: ImageCache
    let delegate: SessionDataDelegate = SessionDataDelegate()
    open var automaticallyAdjustsSize = true

    /**
        Use to kill or keep a fetching image loader when it's blocks is to empty by imageview or anyone.
    */
    open var shouldKeepLoader = false

    fileprivate let decompressingQueue = DispatchQueue(label: "uk.co.motionly.appleBRTV.decompressingQueue", attributes: DispatchQueue.Attributes.concurrent)

    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default,
        cache: ImageCache = Diskcached()
        ) {
            session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
            self.cache = cache
    }

    // MARK: state

    var state: State {

        var status = State.ready
        for loader in delegate.loaders.values {
            switch loader.state {
            case .running:
                status = .running
            case .suspended:
                if status == .ready {
                    status = .suspended
                }
            default:
                break
            }
        }
        return status
    }

    // MARK: loading

    func load(_ URL: URLLiteralConvertible) -> Loader {
        if let loader = delegate[URL.imageLoaderURL] {
            loader.resume()
            return loader
        }

        var request = URLRequest(url: URL.imageLoaderURL)
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request)

        let loader = Loader(task: task, delegate: self)
        delegate[URL.imageLoaderURL] = loader
        return loader
    }

    func suspend(_ URL: URLLiteralConvertible) -> Loader? {
        if let loader = delegate[URL.imageLoaderURL] {
            loader.suspend()
            return loader
        }

        return nil
    }

    func cancel(_ URL: URLLiteralConvertible, block: Block? = nil) -> Loader? {
        if let loader = delegate[URL.imageLoaderURL] {
            if let block = block {
                loader.remove(block)
            }

            if !shouldKeepLoader && loader.blocks.count == 0 {
                loader.cancel()
                delegate.remove(URL.imageLoaderURL)
            }
            return loader
        }

        return nil
    }

    class SessionDataDelegate: NSObject, URLSessionDataDelegate {

        fileprivate let _queue = DispatchQueue(label: "uk.co.motionly.appleBRTV.SessionDataDelegate", attributes: DispatchQueue.Attributes.concurrent)
        fileprivate var loaders = [URL: Loader]()

        subscript (URL: URL) -> Loader? {
            get {
                var loader : Loader?
                _queue.sync {
                    loader = self.loaders[URL]
                }
                return loader
            }
            set {
                if let newValue = newValue {
                    _queue.async(flags: .barrier, execute: {
                        self.loaders[URL] = newValue
                    }) 
                }
            }
        }

        fileprivate func remove(_ URL: Foundation.URL) -> Loader? {
            if let loader = self[URL] {
                loaders[URL] = nil
                return loader
            }
            return nil
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            if let URL = dataTask.originalRequest?.url, let loader = self[URL] {
                loader.receive(data)
            }
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(.allow)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let URL = task.originalRequest?.url, let loader = self[URL] {
                loader.complete(error as NSError?)
                remove(URL)
            }
        }
    }
}

/**
    Responsible for sending a request and receiving the response and calling blocks for the request.
*/
open class Loader {

    unowned let delegate: Manager
    let task: URLSessionDataTask
    var receivedData = NSMutableData()
    internal var blocks: [Block] = []

    init (task: URLSessionDataTask, delegate: Manager) {
        self.task = task
        self.delegate = delegate
        resume()
    }

    var state: URLSessionTask.State {
        return task.state
    }

    open func completionHandler(_ completionHandler: @escaping CompletionHandler) -> Self {
        let block = Block(completionHandler: completionHandler)
        return appendBlock(block)
    }

    func appendBlock(_ block: Block) -> Self {
        blocks.append(block)
        return self
    }

    // MARK: task

    open func suspend() {
        task.suspend()
    }

    open func resume() {
        task.resume()
    }

    open func cancel() {
        task.cancel()
    }

    fileprivate func remove(_ block: Block) {
        // needs to queue with sync
        blocks = blocks.filter{ !$0.isEqual(block) }
    }

    fileprivate func receive(_ data: Data) {
        receivedData.append(data)
    }

    fileprivate func complete(_ error: NSError?) {

        if let URL = task.originalRequest?.url {
            if let error = error {
                failure(URL, error: error)
                return
            }
            delegate.decompressingQueue.async {
                self.success(URL, data: self.receivedData as Data)
            }
        }
    }

    fileprivate func success(_ URL: Foundation.URL, data: Data) {
        let image = UIImage(data: data)
        _toCache(URL, image: image)

        for block: Block in blocks {
            block.completionHandler(URL, image, nil, .none)
        }
        blocks = []
    }

    fileprivate func failure(_ URL: Foundation.URL, error: NSError) {
        for block: Block in blocks {
            block.completionHandler(URL, nil, error, .none)
        }
        blocks = []
    }

    fileprivate func _toCache(_ URL: Foundation.URL, image: UIImage?) {
        if let image = image {
            delegate.cache[URL] = image
        }
    }

}

// MARK: singleton instance
public let sharedInstance = Manager()

/**
    Creates `Loader` object using the shared manager instance for the specified URL.
*/
public func load(_ URL: URLLiteralConvertible) -> Loader {
    return sharedInstance.load(URL)
}

/**
    Suspends `Loader` object using the shared manager instance for the specified URL.
*/
public func suspend(_ URL: URLLiteralConvertible) -> Loader? {
    return sharedInstance.suspend(URL)
}

/**
    Cancels `Loader` object using the shared manager instance for the specified URL.
*/
public func cancel(_ URL: URLLiteralConvertible) -> Loader? {
    return sharedInstance.cancel(URL)
}

/**
    Fetches the image using the shared manager instance's `ImageCache` object for the specified URL.
*/
public func cache(_ URL: URLLiteralConvertible) -> UIImage? {
    return sharedInstance.cache[URL.imageLoaderURL]
}

public var state: State {
    return sharedInstance.state
}
