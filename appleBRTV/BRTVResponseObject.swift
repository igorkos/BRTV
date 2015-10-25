//
//  BRTVResponseObject.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/22/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

class BRTVResponseObject : JSONDecodable{
    
    var response : AnyObject?
    //MARK: JSON parsing    
    required init( response:AnyObject?){
        self.response = response
    }
    
    static func create(response:AnyObject?) -> BRTVResponseObject {
        return BRTVResponseObject(response:response)
    }
    
    static func decode(json: JSON) -> BRTVResponseObject? {
        return _JSONAnyObject(json) >>> { d in
            BRTVResponseObject.create(d)
        }
    }
    
}