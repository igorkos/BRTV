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
    case vodMain = 1, vodTumbnail = 3,
    
    chanelLogoTransparent = 4, chanelLogoWhite = 6, chanelLogoEPGV1 = 7, chanelLogoNameEPGV1 = 8,chanelLogoEPGV2 = 9, chanelLogoOriginal = 10,
    
    tvProgram = 11, tvProgramMovie = 12, tvProgramPersonnel = 13, tvProgramEPG = 28,
    
    defaultImage = 14,
    
    archiveStandartThumbnails = 16, archiveStbSmallThumbnails = 18,
    
    movieStbCombined = 19
  }

enum MediaContentType : Int{
    case archive = 1, live = 4
}

class BRTVAPI: NSObject {

    static let sharedInstance = BRTVAPI()
    var applicationName = "IPHONE"
    var imageURLTemplate : String? = nil
    fileprivate var serverURL = URL(string: "http://ivsmedia.iptv-distribution.net/Json")!
    fileprivate let serviceSuffix = ".svc/json/"
    fileprivate var sessionID: String? = nil
    
    //TODO: load from user settings ( possible values from getMediaZoneInfo() call )
    fileprivate var streamTimeZone = "EU_RST"
    fileprivate var watchingZone = "NA_PST"
    
    
    // MARK: Login
    func login(_ username: String, password: String, completion: @escaping APIResponseBlock)
    {
        
 
        let request = NSMutableURLRequest(url: getFullRequestURL(.ClientService, method: .Login))
        
        let data = ["cc": ["appSettings" : ["appName" : applicationName, "siteID" : 0, "settings" : []],
            "clientCredentials": ["UserLogin": username, "UserPassword" : password]]]
       
        performRequest(request, jsonObject: data as AnyObject?, result:ClientAppSettings.self, completion:{
            (response: AnyObject?, error: Error?) in
            if error != nil {
                completion(nil, error)
            }
            else{
                let settings = response as? ClientAppSettings
                self.sessionID = settings!.sessionID
                completion(response, error)
            }
            
        })
    }
    
    
    // MARK: Channels
    func getClientChannels(_ completion: @escaping APIResponseBlock)
    {
        let request = NSMutableURLRequest(url: getFullRequestURL(.ContentService, method: .GetClientChannels))
        
        if sessionID == nil
        {
            completion(nil, NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        let data = ["sessionID" : sessionID!, "request":["type":4]] as [String : Any]
        
        performRequest(request, jsonObject: data as AnyObject?, result:BRTVResponseObject.self, completion:completion)
    }
    
    func getClientTVGrid(_ start: DateTime, end: DateTime, page:Int,  completion: @escaping APIResponseBlock)
    {
        let request = NSMutableURLRequest(url: getFullRequestURL(.ContentService, method: .GetTVGrid))
        
        if sessionID == nil
        {
            completion(nil, NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
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
        ] as [String : Any]
        
        performRequest(request, jsonObject: data as AnyObject?, result:TVGrid.self, completion:completion)
    }

    // MARK: Archive
    func getClientArchiveChannels(_ completion: @escaping APIResponseBlock)
    {
        let request = NSMutableURLRequest(url: getFullRequestURL(.ContentService, method: .GetClientChannels))
        
        if sessionID == nil
        {
            completion(nil, NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        let data = ["sessionID" : sessionID!, "request":["type":1]] as [String : Any]
        
        performRequest(request, jsonObject: data as AnyObject?, result:BRTVResponseArrayObject<ArchiveChannel>.self, completion:completion)
    }
    
    func getArchiveTimeSpan(_ channel: Int,completion: @escaping APIResponseBlock)
    {
        let request = NSMutableURLRequest(url: getFullRequestURL(.ContentService, method: .GetArchiveTimeSpan))
        
        let data = ["channelID" : channel]
        
        performRequest(request, jsonObject: data as AnyObject?, result:BRTVResponseObject.self, completion:completion)
    }
    
    func getArchiveProgramGuide(_ channel: Int,page:Int,completion: @escaping APIResponseBlock){
        let request = NSMutableURLRequest(url: getFullRequestURL(.ContentService, method: .GetClientProgramGuide))
        
        if sessionID == nil
        {
            completion(nil, NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
            return;
        }
        
        let start = DateTime() - Duration(1200000)
        let end = DateTime() + Duration(86400)
      
        let data = ["sessionID" : sessionID!,"type":MediaContentType.archive.rawValue,
                "request":[
                    "type":MediaContentType.archive.rawValue,
                    "filter":[
                        "DontFetchDetails": false,
                        "availableOnly": true,
                        "contentType": MediaContentType.archive.rawValue,
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
        ] as [String : Any]
    
        performRequest(request, jsonObject: data as AnyObject?, result:AchiveChannelPrograms.self, completion:completion)
    }
    
    // MARK: Stream URI
    func getStreamURI(_ itemID: Int, type :MediaContentType, completion: @escaping APIResponseBlock)
    {
        let request = NSMutableURLRequest(url: getFullRequestURL(.MediaService, method: .GetClientStreamUri))
        
        if sessionID == nil
        {
            completion(nil, NSError(domain: "SessionID Error Domain", code: 400, userInfo: nil))
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
            ]] as [String : Any]
        let callback = completion
        performRequest(request, jsonObject: data as AnyObject?, result:BRTVResponseObject.self, completion:{
            (response: AnyObject?, error: Error?) in
            guard let result = response as? BRTVResponseObject else {
                callback(nil, error)
                return
            }
            callback(result.response, nil)
        })
    }
    
    // MARK: Media image URI
    func getMediaImageType(_ completion: @escaping APIResponseBlock)
    {
        let request = NSMutableURLRequest(url: getFullRequestURL(.MediaService, method: .GetMediaImageTypes))
        
        let data = [] as AnyObject
        
        performRequest(request, jsonObject: data as AnyObject?, result:BRTVResponseObject.self, completion:completion)
    }
    
    //Seedup image loding in case if template is loaded from service
    
    
    func getImageURIs(_ itemID: Int, mediaType : BRTVAPIImageType, index: Int,  completion: @escaping APIResponseBlock)
    {
        if self.imageURLTemplate != nil {
            var templateURL = self.imageURLTemplate
            templateURL = templateURL!.replacingOccurrences(of: "{0}", with: "\(itemID)")
            templateURL = templateURL!.replacingOccurrences(of: "{1}", with: "\(mediaType.rawValue)")
            templateURL = templateURL!.replacingOccurrences(of: "{2}", with: "\(index)")
            completion(templateURL as AnyObject?, nil)
            return
        }
        let request = NSMutableURLRequest(url: getFullRequestURL(.MediaService, method: .GetImageUrl))

        let data = ["siteID" : 1]
        let callback = completion
        
        performRequest(request, jsonObject: data as AnyObject?, result:BRTVResponseObject.self, completion:{
            (response: AnyObject?, error: Error?) in
            
            guard let result = response as? BRTVResponseObject else {
                callback(nil, error)
                return
            }
            
            self.imageURLTemplate = result.response as? String
            guard var templateURL = self.imageURLTemplate else {
                callback(nil, nil)
                return
            }
            
            templateURL = templateURL.replacingOccurrences(of: "\\", with: "")
            templateURL = templateURL.replacingOccurrences(of: "\"", with: "")
            self.imageURLTemplate = templateURL
            
            //        http://hostname/ui/ImageHandler.ashx?e={0}&t={1}&n={2}
            //        {0} - content item id (channel id, movie id, program id)
            //        {1} - type id (use GetMediaImageTypes to get all possible image types)
            //        {2} - order number of an image for specified content item id and type. if omitted is always = 1
            
            templateURL = templateURL.replacingOccurrences(of: "{0}", with: "\(itemID)")
            templateURL = templateURL.replacingOccurrences(of: "{1}", with: "\(mediaType.rawValue)")
            templateURL = templateURL.replacingOccurrences(of: "{2}", with: "\(index)")
            callback(templateURL as AnyObject?, nil)
        })
    }

    func getMediaZoneInfo(_ completion: @escaping APIResponseBlock)
    {
        let request = NSMutableURLRequest(url: getFullRequestURL(.MediaService, method: .GetMediaZoneInfo))
        
        let data = [] as AnyObject
        
        performRequest(request, jsonObject: data as AnyObject?, result:BRTVResponseObject.self, completion:completion)
    }
    
    
    fileprivate func getFullRequestURL(_ service: BRTVAPIService, method: BRTVAPIMethod) -> URL
    {
        let fullURLStr = serverURL.absoluteString + service.rawValue + serviceSuffix + method.rawValue
        return URL(string: fullURLStr)!
    }
    
    
    
    
    
    
}
