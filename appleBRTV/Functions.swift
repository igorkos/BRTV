//
//  Functions.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 13/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class Functions: NSObject {
    class func getUrlProtectionSpace() -> URLProtectionSpace
    {
        let url = URL(string: "http://bestrussiantv.com")!
        
        
        
        let protectionSpace = URLProtectionSpace(host: url.host!, port: 8000, protocol: url.scheme, realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPDigest)
        
        return protectionSpace
    }    

    class func loadImage(_ itemID: Int, mediaType : BRTVAPIImageType, index: Int, imageView: UIImageView){
        let api = BRTVAPI.sharedInstance
        guard api.imageURLTemplate != nil else {
            api.getImageURIs(itemID, mediaType : mediaType, index: index,  completion: {(response: AnyObject?, error: Error?) in
                guard let imageURL = URL(string: response as! String) else {
                    return
                }
                imageView.loadImage(imageURL)
            })
            return
        }
        var templateURL = api.imageURLTemplate
        templateURL = templateURL?.replacingOccurrences(of: "{0}", with: "\(itemID)")
        templateURL = templateURL?.replacingOccurrences(of: "{1}", with: "\(mediaType.rawValue)")
        templateURL = templateURL?.replacingOccurrences(of: "{2}", with: "\(index)")
        let imageURL = URL(string: templateURL!)!
        imageView.loadImage(imageURL)
    }
    
}
