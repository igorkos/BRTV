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
    case ClientService = "ClientService", ContentService = "ContentService", MediaService = "MediaService"
}

enum BRTVAPIMethod : String
{
    case Login = "Login", GetClientChannels = "GetClientChannels", GetClientStreamUri = "GetClientStreamUri"
}

public typealias APIResponseBlock = ((response: AnyObject?, error: NSError?) -> ())

class BRTVAPI: NSObject {

    static let sharedInstance = BRTVAPI()
    var applicationName = "IPHONE"
    var serverURL = NSURL(string: "http://ivsmedia.iptv-distribution.net/Json")!
    private let serviceSuffix = ".svc/json/"
    
    
    
    // MARK: Login
    func login(username: String, password: String, completion: APIResponseBlock)
    {
        
 
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ClientService, method: .Login))
        
        let data = ["cc": ["appSettings" : ["appName" : applicationName, "siteID" : 0, "settings" : []],
            "clientCredentials": ["UserLogin": username, "UserPassword" : password]]]
       
        handlePOSTRequest(request, jsonObject: data, completion: completion)
        
    }
    
    
    // MARK: Channels
    func getClientChannels(sessionID: String, completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ContentService, method: .GetClientChannels))
        
        let dataDict = ["sessionID" : sessionID, "request":["type":4]]
        
        handlePOSTRequest(request, jsonObject: dataDict, completion: completion)
    }
    
    
    // MARK: Stream URI
    func getStreamURI(itemID: Int, sessionID: String, completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetClientStreamUri))
        
        let data = ["sessionID" : sessionID, "mediaRequest":[
            "item" : ["id": itemID, "contentType" : 4],
            "streamSettings" : [
                "balancingArea" : ["id" : 4],
                "cdn" : ["id" : 1],
                "qualityPreset" : 1,
                "shiftTimeZoneName" : "NA_EST"
            ]
            ]]
        
        handlePOSTRequest(request, jsonObject: data, completion: completion)
    }
    
    // MARK: Helpers
    
    private func handlePOSTRequest(request: NSMutableURLRequest, jsonObject: AnyObject, completion: APIResponseBlock)
    {
        request.HTTPMethod = "POST"
        
        do {
            
            let dataStr = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
            
            request.HTTPBody = dataStr
            
            let dataTask = getSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                
                if error != nil
                {
                    completion(response: nil, error: error)
                    return
                }
                
                if data == nil && response != nil
                {
                    completion(response: nil, error: NSError(domain: "Data error domain", code: 400, userInfo: ["url response" : response!]))
                    return
                }
                
                do
                {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    completion(response: jsonData, error: nil)
                }
                catch let error as NSError
                {
                    completion(response: nil, error: error)
                }
                
                
            })
            
            dataTask.resume()
        }
        catch let error as NSError
        {
            completion(response: nil, error: error)
            print("json error: \(error)")
            
        }

    }
    
    private func getSession() -> NSURLSession
    {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        sessionConfig.HTTPAdditionalHeaders = ["Content-Type" : "application/json"]
        
        let session = NSURLSession(configuration: sessionConfig)
        return session
    }
    
    private func getFullRequestURL(service: BRTVAPIService, method: BRTVAPIMethod) -> NSURL
    {
        let fullURLStr = serverURL.absoluteString + service.rawValue + serviceSuffix + method.rawValue
        return NSURL(string: fullURLStr)!
    }
    
    
    
}
