//
//  BRTVAPI.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 10/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

enum BRTVAPIService : String
{
    case ClientService = "ClientService"
}

enum BRTVAPIMethod : String
{
    case Login = "Login"
}

public typealias APIResponseBlock = ((response: AnyObject?, error: NSError?) -> ())

class BRTVAPI: NSObject {

    static let sharedInstance = BRTVAPI()
    var applicationName = "WEBPLAYER"
    var serverURL = NSURL(string: "http://ivsmedia.iptv-distribution.net/Json")!
    private let serviceSuffix = ".svc/json/"
    
    
    
    // MARK: Login
    func login(username: String, password: String) -> APIResponseBlock
    {
        
        return (response: nil, error: nil)
    }
    
    
    // MARK: Helpers
    
    private func getFullRequestURL(service: BRTVAPIService, method: BRTVAPIMethod) -> NSURL
    {
        let fullURLStr = serverURL.absoluteString + service.rawValue + serviceSuffix + method.rawValue
        return NSURL(string: fullURLStr)!
    }
    
    
    
}
