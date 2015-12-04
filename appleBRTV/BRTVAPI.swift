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
    case Login = "Login", GetClientChannels = "GetClientChannels", GetClientStreamUri = "GetClientStreamUri", GetTVGrid = "GetTVGrid", GetImageUrl = "MediaImageUrlTemplate", GetMediaImageTypes = "GetMediaImageTypes", GetMediaZoneInfo = "GetMediaZoneInfo",GetArchiveTimeSpan="GetArchiveTimeSpan",GetClientProgramGuide = "GetClientProgramGuide"
}

enum BRTVAPIImageType : Int{
    case VODMain = 1, VODTumbnail = 3,
    
    ChanelLogoTransparent = 4, ChanelLogoWhite = 6, ChanelLogoEPGV1 = 7, ChanelLogoNameEPGV1 = 8,ChanelLogoEPGV2 = 9, ChanelLogoOriginal = 10,
    
    TVProgram = 11, TVProgramMovie = 12, TVProgramPersonnel = 13, TVProgramEPG = 28,
    
    DefaultImage = 14,
    
    ArchiveStandartThumbnails = 16, ArchiveStbSmallThumbnails = 18,
    
    MovieStbCombined = 19
  }

enum MediaContentType : Int{
    case Archive = 1, Live = 4
}

class BRTVAPI: NSObject {

    static let sharedInstance = BRTVAPI()
    var applicationName = "IPHONE"
    var imageURLTemplate : String? = nil
    private var serverURL = NSURL(string: "http://ivsmedia.iptv-distribution.net/Json")!
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
       
        performRequest(request, jsonObject: data, result:ClientAppSettings.self, completion:{
            (response: AnyObject?, error: ErrorType?) in
            guard error == nil else {
                return completion(response: nil, error: error)
            }
            let settings = response as? ClientAppSettings
            self.sessionID = settings!.sessionID
            completion(response: response, error: error)
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
        
        let data = ["sessionID" : sessionID!, "request":["type":4]]
        
        performRequest(request, jsonObject: data, result:BRTVResponseObject.self, completion:completion)
    }
    
    func getClientTVGrid(start: DateTime, end: DateTime, page:Int,  completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ContentService, method: .GetTVGrid))
        
        if sessionID == nil
        {
            completion(response: nil, error: NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        let data = ["sessionID" : sessionID!, "request":[
            "paging":["itemsOnPage": 7,"pageNumber": page ],
            "fromTime": start.toJsonDateString(),
            "tillTime": end.toJsonDateString(),
            "streamZone": streamTimeZone,
            "watchingZone": streamTimeZone,
            "showDetails": true,
            "utcTime": true
            ]
        ]
        
        performRequest(request, jsonObject: data, result:TVGrid.self, completion:completion)
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
        
        let data = ["sessionID" : sessionID!, "request":["type":1]]
        
        performRequest(request, jsonObject: data, result:BRTVResponseArrayObject<ArchiveChannel>.self, completion:completion)
    }
    
    func getArchiveTimeSpan(channel: Int,completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ContentService, method: .GetArchiveTimeSpan))
        
        let data = ["channelID" : channel]
        
        performRequest(request, jsonObject: data, result:BRTVResponseObject.self, completion:completion)
    }
    
    func getArchiveProgramGuide(channel: Int,page:Int,completion: APIResponseBlock){
        let request = NSMutableURLRequest(URL: getFullRequestURL(.ContentService, method: .GetClientProgramGuide))
        
        if sessionID == nil
        {
            completion(response: nil, error: NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        let start = DateTime() - Duration(1200000)
        let end = DateTime() + Duration(86400)
      
        let data = ["sessionID" : sessionID!,"type":MediaContentType.Archive.rawValue,
                "request":[
                    "type":MediaContentType.Archive.rawValue,
                    "filter":[
                        "DontFetchDetails": false,
                        "availableOnly": true,
                        "contentType": MediaContentType.Archive.rawValue,
                        "visibleOnly": true,
                        "studioID": channel,
                        "date": start.toJsonDateString(),
                        "dateTill": end.toJsonDateString(),
                        "orderBy": "movie_date ASC"
                        ],
                    "paging":["itemsOnPage": 50,"pageNumber": page],
                    "requestType": 0,
                    "channelID": channel,
                    "streamZone":  streamTimeZone,
                    "watchingZone": streamTimeZone,
                    "utcTime": true
                ]
        ]
    
        performRequest(request, jsonObject: data, result:AchiveChannelPrograms.self, completion:completion)
    }
    
    // MARK: Stream URI
    func getStreamURI(itemID: Int, type :MediaContentType, completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetClientStreamUri))
        
        if sessionID == nil
        {
            completion(response: nil, error: NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        
        let data = ["sessionID" : sessionID!, "mediaRequest":[
            "item" : ["id": itemID, "contentType" : type.rawValue],
            "streamSettings" : [
                "balancingArea" : ["id" : 4],
                "cdn" : ["id" : 1],
                "qualityPreset" : 1,
                "shiftTimeZoneName" : streamTimeZone
            ]
            ]]
        let callback = completion
        performRequest(request, jsonObject: data, result:BRTVResponseObject.self, completion:{
            (response: AnyObject?, error: ErrorType?) in
            guard let result = response as? BRTVResponseObject else {
                callback(response: nil, error: error)
                return
            }
            callback(response: result.response, error: nil)
        })
    }
    
    // MARK: Media image URI
    func getMediaImageType(completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetMediaImageTypes))
        
        let data = []
        
        performRequest(request, jsonObject: data, result:BRTVResponseObject.self, completion:completion)
    }
    
    //Seedup image loding in case if template is loaded from service
    
    
    func getImageURIs(itemID: Int, mediaType : BRTVAPIImageType, index: Int,  completion: APIResponseBlock)
    {
        if self.imageURLTemplate != nil {
            var templateURL = self.imageURLTemplate
            templateURL = templateURL!.stringByReplacingOccurrencesOfString("{0}", withString: "\(itemID)")
            templateURL = templateURL!.stringByReplacingOccurrencesOfString("{1}", withString: "\(mediaType.rawValue)")
            templateURL = templateURL!.stringByReplacingOccurrencesOfString("{2}", withString: "\(index)")
            completion(response: templateURL, error: nil)
            return
        }
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetImageUrl))

        let data = ["siteID" : 1]
        let callback = completion
        
        performRequest(request, jsonObject: data, result:BRTVResponseObject.self, completion:{
            (response: AnyObject?, error: ErrorType?) in
            
            guard let result = response as? BRTVResponseObject else {
                callback(response: nil, error: error)
                return
            }
            
            self.imageURLTemplate = result.response as? String
            guard var templateURL = self.imageURLTemplate else {
                callback(response: nil, error: nil)
                return
            }
            
            templateURL = templateURL.stringByReplacingOccurrencesOfString("\\", withString: "")
            templateURL = templateURL.stringByReplacingOccurrencesOfString("\"", withString: "")
            self.imageURLTemplate = templateURL
            
            //        http://hostname/ui/ImageHandler.ashx?e={0}&t={1}&n={2}
            //        {0} - content item id (channel id, movie id, program id)
            //        {1} - type id (use GetMediaImageTypes to get all possible image types)
            //        {2} - order number of an image for specified content item id and type. if omitted is always = 1
            
            templateURL = templateURL.stringByReplacingOccurrencesOfString("{0}", withString: "\(itemID)")
            templateURL = templateURL.stringByReplacingOccurrencesOfString("{1}", withString: "\(mediaType.rawValue)")
            templateURL = templateURL.stringByReplacingOccurrencesOfString("{2}", withString: "\(index)")
            callback(response: templateURL, error: nil)
        })
    }

    func getMediaZoneInfo(completion: APIResponseBlock)
    {
        let request = NSMutableURLRequest(URL: getFullRequestURL(.MediaService, method: .GetMediaZoneInfo))
        
        let data = []
        
        performRequest(request, jsonObject: data, result:BRTVResponseObject.self, completion:completion)
    }
    
    
    private func getFullRequestURL(service: BRTVAPIService, method: BRTVAPIMethod) -> NSURL
    {
        let fullURLStr = serverURL.absoluteString + service.rawValue + serviceSuffix + method.rawValue
        return NSURL(string: fullURLStr)!
    }
    
    
    
    
    
    
}
