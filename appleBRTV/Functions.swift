//
//  Functions.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 13/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class Functions: NSObject {
    class func getUrlProtectionSpace() -> NSURLProtectionSpace
    {
        let url = NSURL(string: "http://bestrussiantv.com")!
        
        
        
        let protectionSpace = NSURLProtectionSpace(host: url.host!, port: 8000, `protocol`: url.scheme, realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPDigest)
        
        return protectionSpace
    }    

    class func loadImage(itemID: Int, mediaType : BRTVAPIImageType, index: Int, imageView: UIImageView){
        let api = BRTVAPI.sharedInstance
        guard api.imageURLTemplate != nil else {
            api.getImageURIs(itemID, mediaType : mediaType, index: index,  completion: {(response: AnyObject?, error: ErrorType?) in
                guard let imageURL = NSURL(string: response as! String) else {
                    return
                }
                imageView.loadImage(imageURL)
            })
            return
        }
        var templateURL = api.imageURLTemplate
        templateURL = templateURL?.stringByReplacingOccurrencesOfString("{0}", withString: "\(itemID)")
        templateURL = templateURL?.stringByReplacingOccurrencesOfString("{1}", withString: "\(mediaType.rawValue)")
        templateURL = templateURL?.stringByReplacingOccurrencesOfString("{2}", withString: "\(index)")
        let imageURL = NSURL(string: templateURL!)!
        imageView.loadImage(imageURL)
    }
    
}
