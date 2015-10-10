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
    func login(username: String, password: String, completion: APIResponseBlock)
    {
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ClientService, method: .Login))
        request.HTTPMethod = "POST"
        
        let data = ["cc": ["appSettings" : applicationName, "siteID" : 0, "settings" : []],
            "clientCredentials": ["UserLogin": username, "UserPassword" : password]]
       
        do {
            let dataStr = try NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
            request.HTTPBody = dataStr
            
            let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                
                if error != nil
                {
                    completion(response: nil, error: error)
                    return
                }
                
                
                do
                {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    completion(response: jsonData, error: nil)
                }
                catch let error as NSError
                {
                    completion(response: nil, error: error)
                }
                
                
            })
            
            dataTask.resume()
        }
        catch
        {
//            completion(response: nil, error: error)
            print("json error: \(error)")

        }
        
    }
    
    
    // MARK: Helpers
    
    private func getFullRequestURL(service: BRTVAPIService, method: BRTVAPIMethod) -> NSURL
    {
        let fullURLStr = serverURL.absoluteString + service.rawValue + serviceSuffix + method.rawValue
        return NSURL(string: fullURLStr)!
    }
    
    
    
}
