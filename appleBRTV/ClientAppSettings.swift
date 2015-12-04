//
//  ClientAppSettings.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/22/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

class ClientAppSettings : JSONDecodable{
    
    //MARK: JSON parsing
    var appSettings : Dictionary<String,AnyObject>?
    var clientCredentials :  Dictionary<String,AnyObject>?
    
    required init( appSettings:Dictionary<String,AnyObject>?, clientCredentials:Dictionary<String,AnyObject>?){
        self.appSettings = appSettings
        self.clientCredentials = clientCredentials
    }
    
    static func create(appSettings: Dictionary<String,AnyObject>)(clientCredentials: Dictionary<String,AnyObject>) -> ClientAppSettings {
        return ClientAppSettings(appSettings:appSettings,clientCredentials: clientCredentials)
    }
    
    static func decode(json: JSON) -> ClientAppSettings? {
        return _JSONObject(json) >>> { d in
            ClientAppSettings.create <^>
                _JSONObject(d["appSettings"])    <*>
                _JSONObject(d["clientCredentials"])
        }
    }
    static func arrayKey() ->String{
        return ""
    }
    //MARK: properies
    lazy var  sessionID : String = {
        let id :String = self.clientCredentials!["sessionID"] as! String
        return id
    }()
}