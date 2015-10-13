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

    
    // Used to remove splash and login from navigation stacks where necessary (so back takes to the apple tv screen)
    class func clearNavigationStack()
    {
        
    }
}
