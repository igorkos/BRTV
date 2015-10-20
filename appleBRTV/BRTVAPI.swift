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
    case Login = "Login", GetClientChannels = "GetClientChannels", GetClientStreamUri = "GetClientStreamUri", GetTVGrid = "GetTVGrid", GetImageUrl = "MediaImageUrlTemplate", GetMediaImageTypes = "GetMediaImageTypes", GetMediaZoneInfo = "GetMediaZoneInfo"
}

enum BRTVAPIImageType : Int{
    case VODMain = 1, VODTumbnail = 3,
    
    ChanelLogoTransparent = 4, ChanelLogoWhite = 6, ChanelLogoEPGV1 = 7, ChanelLogoNameEPGV1 = 8,ChanelLogoEPGV2 = 9, ChanelLogoOriginal = 10,
    
    TVProgram = 11, TVProgramMovie = 12, TVProgramPersonnel = 13, TVProgramEPG = 28,
    
    DefaultImage = 14,
    
    ArchiveStandartThumbnails = 16, ArchiveStbSmallThumbnails = 18,
    
    MovieStbCombined = 19
  }

public typealias APIResponseBlock = ((response: AnyObject?, error: NSError?) -> ())

class BRTVAPI: NSObject {

    static let sharedInstance = BRTVAPI()
    var applicationName = "IPHONE"
    var serverURL = NSURL(string: "http://ivsmedia.iptv-distribution.net/Json")!
    private let serviceSuffix = ".svc/json/"
    private var sessionID: String? = nil
    
    //TODO: load from user settings ( possible values from getMediaZoneInfo() call )
    private var streamTimeZone = "EU_RST"
    private var watchingZone = "NA_PST"
    
    // MARK: Login
    func login(username: String, password: String, completion: APIResponseBlock)
    {
        
 
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ClientService, method: .Login))
        
        let data = ["cc": ["appSettings" : ["appName" : applicationName, "siteID" : 0, "settings" : []],
            "clientCredentials": ["UserLogin": username, "UserPassword" : password]]]
       
        handlePOSTRequest(request, jsonObject: data, completion: { (response: AnyObject?, error: NSError?) in
            if response is NSDictionary
            {
                if let credentials = response!["clientCredentials"] as? NSDictionary
                {
                    if let sessionID = credentials["sessionID"] as? String
                    {
                        if sessionID.characters.count > 0
                        {
                            // successful login
                            self.sessionID = sessionID
                            completion(response: response, error: error)
                            return;
                        }
                    }
                }
            }
            
            completion(response: response, error: NSError(domain: "Login error domain", code: 400, userInfo: nil))
            
        })
        
    }
    
    
    // MARK: Channels
    func getClientChannels(completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ContentService, method: .GetClientChannels))
        
        if sessionID == nil
        {
            completion(response: nil, error: NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        let dataDict = ["sessionID" : sessionID!, "request":["type":4]]
        
        handlePOSTRequest(request, jsonObject: dataDict, completion: completion)
    }
    
    func getClientTVGrid(start: NSDate, end: NSDate, page:Int,  completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ContentService, method: .GetTVGrid))
        
        if sessionID == nil
        {
            completion(response: nil, error: NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        let s1  = Int64(start.timeIntervalSince1970 * 1000)
        let e1  = Int64(end.timeIntervalSince1970 * 1000)
        
        let dataDict = ["sessionID" : sessionID!, "request":[
            "paging":["itemsOnPage": 7,"pageNumber": page ],
            "fromTime": "/Date(\(s1))/",
            "tillTime": "/Date(\(e1))/",
            "streamZone": streamTimeZone,
            "watchingZone": streamTimeZone,
            "showDetails": true,
            "utcTime": true
            ]
        ]
        
        handlePOSTRequest(request, jsonObject: dataDict, completion: completion)
    }

    // MARK: Archive
    func getClientArchiveChannels(completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ContentService, method: .GetClientChannels))
        
        if sessionID == nil
        {
            completion(response: nil, error: NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        let dataDict = ["sessionID" : sessionID!, "request":["type":8]]
        
        handlePOSTRequest(request, jsonObject: dataDict, completion: completion)
    }

    
    // MARK: Stream URI
    func getStreamURI(itemID: Int, completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetClientStreamUri))
        
        if sessionID == nil
        {
            completion(response: nil, error: NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        
        let data = ["sessionID" : sessionID!, "mediaRequest":[
            "item" : ["id": itemID, "contentType" : 4],
            "streamSettings" : [
                "balancingArea" : ["id" : 4],
                "cdn" : ["id" : 1],
                "qualityPreset" : 1,
                "shiftTimeZoneName" : streamTimeZone
            ]
            ]]
        
        handlePOSTRequest(request, jsonObject: data, completion: completion)
    }
    
    // MARK: Media image URI
    func getMediaImageType(completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetMediaImageTypes))
        
        let data = []
        
        handlePOSTRequest(request, jsonObject: data ,completion: completion)
    }
    
    
    func getImageURIs(itemID: Int, mediaType : BRTVAPIImageType, index: Int,  completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetImageUrl))

        let data = ["siteID" : 1]
        let callback = completion
        
        handlePOSTRequest(request, jsonObject: data ,completion: {
            (response: AnyObject?, error: NSError?) in
            var templateURL = response as? String
            if templateURL != nil {
            //        http://hostname/ui/ImageHandler.ashx?e={0}&t={1}&n={2}
            //        {0} - content item id (channel id, movie id, program id)
            //        {1} - type id (use GetMediaImageTypes to get all possible image types)
            //        {2} - order number of an image for specified content item id and type. if omitted is always = 1
                templateURL = templateURL?.stringByReplacingOccurrencesOfString("{0}", withString: "\(itemID)")
                templateURL = templateURL?.stringByReplacingOccurrencesOfString("{1}", withString: "\(mediaType.rawValue)")
                templateURL = templateURL?.stringByReplacingOccurrencesOfString("{2}", withString: "\(index)")
                callback(response: templateURL, error: nil)
            }            
        })
    }

    func getMediaZoneInfo(completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetMediaZoneInfo))
        
        let data = []
        
        handlePOSTRequest(request, jsonObject: data ,completion: completion)
    }
    
    // MARK: Helpers
    private func handlePOSTRequestSync(request: NSMutableURLRequest, jsonObject: AnyObject? ) -> AnyObject?
    {
        let semaphore = dispatch_semaphore_create(0)
        var requestResponse : AnyObject? = nil
        
        handlePOSTRequest(request, jsonObject: jsonObject ,completion: {
            (response: AnyObject?, error: NSError?) in
            requestResponse = response
            dispatch_semaphore_signal(semaphore)
        })

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return requestResponse
    }
    

    private func handlePOSTRequest(request: NSMutableURLRequest, jsonObject: AnyObject?, completion: APIResponseBlock)
    {
        request.HTTPMethod = "POST"
        
        do {
            
            if jsonObject != nil {
                let dataStr = try NSJSONSerialization.dataWithJSONObject(jsonObject!, options: [])
            
                request.HTTPBody = dataStr
            }
            
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
