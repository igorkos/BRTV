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
    static func arrayKey() ->String{
        return ""
    }
}

class BRTVResponseArrayObject<A:JSONDecodable> : JSONDecodable{
    
    var response : Dictionary<String,AnyObject>?
    var array : Array<A> = Array<A>()

    //MARK: JSON parsing
    required init( response:AnyObject?){
        self.response = response as? Dictionary<String,AnyObject>
    }
    
    static func create(response:AnyObject?) -> BRTVResponseArrayObject<A> {
        return BRTVResponseArrayObject<A>(response:response)
    }
    
    static func decode(json: JSON) -> BRTVResponseArrayObject<A>? {
        return _JSONAnyObject(json) >>> { d in
            let object = BRTVResponseArrayObject<A>.create(d)
            let respArray = object.response![A.arrayKey()] as! Array<AnyObject>
            for itemData in respArray {
                let item : A = (A.decode(itemData) as? A)!
                object.array.append(item)
            }
            return object
        }
    }
    static func arrayKey() ->String{
        return ""
    }
}