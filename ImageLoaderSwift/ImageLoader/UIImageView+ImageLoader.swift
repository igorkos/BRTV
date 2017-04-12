//
//  UIImageView+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/17/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

private var ImageLoaderURLKey = 0
private var ImageLoaderBlockKey = 0

/**
    Extension using ImageLoader sends a request, receives image and displays.
*/
extension UIImageView {

    // MARK: - properties

    fileprivate var URL: Foundation.URL? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderURLKey) as? Foundation.URL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    fileprivate var block: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderBlockKey) as AnyObject?
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - public
    public func loadImage(_ URL: URLLiteralConvertible ){
        load(URL, placeholder:nil, completionHandler:nil)
    }
    
    public func load(_ URL: URLLiteralConvertible, placeholder: UIImage? = nil, completionHandler:CompletionHandler? = nil) {
        cancelLoading()

        if let placeholder = placeholder {
            image = placeholder
        }

        self.URL = URL.imageLoaderURL as URL
        _load(URL.imageLoaderURL as URL, completionHandler: completionHandler)
    }

    public func cancelLoading() {
        if let URL = URL {
            sharedInstance.cancel(URL, block: block as? Block)
        }
    }

    // MARK: - private
    fileprivate static let _requesting_queue = DispatchQueue(label: "swift.imageloader.queues.requesting", attributes: [])

    fileprivate func _load(_ URL: Foundation.URL, completionHandler: CompletionHandler?) {

        let _completionHandler: CompletionHandler = { URL, image, error, cacheType in

            DispatchQueue.main.async { [weak self] in
                // requesting is success then set image
                if let wSelf = self, let thisURL = wSelf.URL, let image = image, (thisURL == URL as URL) {
                    if sharedInstance.automaticallyAdjustsSize {
                        wSelf.image = image.adjusts(wSelf.frame.size, scale: UIScreen.main.scale)
                    } else {
                        wSelf.image = image
                    }
                }
                completionHandler?(URL, image, error, cacheType)
            }
        }

        // caching
        if let image = sharedInstance.cache[URL] {
            _completionHandler(URL, image, nil, .cache)
            return
        }

        UIImageView._requesting_queue.async {
            let block = Block(completionHandler: _completionHandler)
            sharedInstance.load(URL).appendBlock(block)
            self.block = block
        }

    }

}
