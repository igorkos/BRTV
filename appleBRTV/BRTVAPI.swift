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
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        sessionConfig.HTTPAdditionalHeaders = ["Content-Type" : "application/json"]
        
        let session = NSURLSession(configuration: sessionConfig)
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ClientService, method: .Login))
        request.HTTPMethod = "POST"
        
        
        let data = ["cc": ["appSettings" : ["appName" : applicationName, "siteID" : 0, "settings" : []],
            "clientCredentials": ["UserLogin": username, "UserPassword" : password, "StbMacAddress": "a4:5e:60:d9:dd:91"]]]
       
        
        do {

            let dataStr = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            
            let testStr = String(data: dataStr, encoding: NSUTF8StringEncoding)!
            print("data: \(testStr)")
            request.HTTPBody = dataStr
            
            let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                
                if error != nil
                {
                    completion(response: nil, error: error)
                    return
                }
                
                
                do
                {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    completion(response: jsonData, error: nil)
                }
                catch let error as NSError
                {
                    
                    print("error: \(error)")
                    let testErrorStr = String(data: data!, encoding: NSUTF8StringEncoding)
                    print("server error: \(testErrorStr)")
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
